# Paso 4: Automatizar la recolección de logs con Grafana Alloy

En el paso anterior instalamos **Grafana Alloy** en nuestro servidor Ubuntu y comprobamos que se encuentra en ejecución. También desplegamos **Grafana Loki** y lo configuramos como *data source* en Grafana, validando la conexión mediante el envío y la visualización de un log de prueba.

Ahora configuraremos **Grafana Alloy** para automatizar la recolección y el envío de los logs de NGINX y del sistema Ubuntu a Grafana Loki.

Para ello, utilizaremos dos componentes de Alloy que nos permiten recopilar logs desde diferentes fuentes:

* **`loki.source.file`:** permite leer logs directamente desde archivos, como los logs de acceso y errores de NGINX.
* **`loki.source.journal`:** permite recopilar los mensajes almacenados en el *systemd journal* de Linux.

Ambos componentes enviarán los logs a Grafana Loki, desde donde podremos consultarlos y visualizarlos utilizando Grafana.

## ¿Qué es el systemd journal?

**systemd journal** es el sistema de registro de eventos de `systemd`, utilizado por muchas distribuciones Linux, incluida Ubuntu. Almacena mensajes del sistema operativo y de los servicios que se ejecutan en el servidor.

Para consultar estos registros desde la terminal, Linux proporciona la herramienta **`journalctl`**, que permite visualizar y filtrar los mensajes del journal según diferentes criterios, como el servicio que los generó o el momento en que se registraron.

En nuestro laboratorio utilizaremos el componente `loki.source.journal` de Grafana Alloy para recopilar estos registros directamente, sin necesidad de ejecutar `journalctl` como parte del proceso de recolección.

## Otorgar permisos a Grafana Alloy

Por motivos de seguridad, Grafana Alloy se ejecuta utilizando un usuario dedicado llamado `alloy`, en lugar de hacerlo como `root`. Para que pueda recopilar los logs del sistema, necesitamos otorgarle los permisos de lectura correspondientes.

En Ubuntu, podemos añadir el usuario `alloy` a los grupos `adm` y `systemd-journal`, que permiten acceder a los registros del sistema y al journal de systemd.

Ejecuta el siguiente comando para agregar el usuario a ambos grupos:

```bash
sudo usermod -aG adm,systemd-journal alloy
```

{{exec}}

Después de modificar los grupos, debemos reiniciar el servicio de Alloy para que los nuevos permisos se apliquen:

```bash
sudo systemctl restart alloy
```

{{exec}}

Podemos comprobar que el usuario pertenece a los grupos ejecutando:

```bash
groups alloy
```

{{exec}}

> **Nota:** Además de los permisos para el journal, Alloy necesita permisos de lectura sobre los archivos de logs de NGINX que vamos a utilizar. En nuestro laboratorio, estos permisos deben estar configurados para el directorio `/var/log/nginx`.

## Configurar Grafana Alloy

Ahora que Alloy cuenta con los permisos necesarios, vamos a configurar sus componentes para recopilar los logs y enviarlos a Grafana Loki.

La configuración se encuentra en el archivo:

```text
/etc/alloy/config.alloy
```

En este archivo definiremos tres componentes:

1. **`loki.write`:** establece el destino al que Alloy enviará los logs.
2. **`local.file_match` y `loki.source.file`:** localizan y recopilan los logs de NGINX desde sus archivos.
3. **`loki.source.journal`:** recopila los logs del sistema Ubuntu desde el journal de systemd.

### 1. Configurar Loki como destino

Primero, definiremos el componente `loki.write`, que se encargará de enviar los logs recopilados por Alloy a nuestro backend, Grafana Loki.

```alloy
loki.write "endpoint" {
  endpoint {
    url = "http://localhost:3100/loki/api/v1/push"
  }
}
```

En esta configuración, la URL `http://localhost:3100/loki/api/v1/push` corresponde al endpoint de escritura de Loki. Como Alloy está instalado directamente en el servidor Ubuntu y el puerto `3100` de Loki está publicado en el host, podemos utilizar `localhost` para establecer la conexión.

El nombre `endpoint` identifica este componente dentro de la configuración de Alloy. Los demás componentes podrán utilizarlo para enviarle los logs.

### 2. Recopilar los logs de NGINX

NGINX almacena sus logs en archivos dentro del directorio `/var/log/nginx/`. Los principales son:

* **`access.log`:** contiene información sobre las solicitudes HTTP recibidas por el servidor.
* **`error.log`:** contiene información sobre errores y otros eventos relacionados con el funcionamiento de NGINX.

Para recopilar estos registros utilizaremos los componentes `local.file_match` y `loki.source.file`.

```alloy
local.file_match "nginx" {
  path_targets = [{
    "__path__" = "/var/log/nginx/*log",
    "host"     = "grafana",
    "service"  = "nginx",
  }]
}

loki.source.file "nginx" {
  targets    = local.file_match.nginx.targets
  forward_to = [loki.write.endpoint.receiver]
}
```

El componente **`local.file_match`** identifica los archivos que coinciden con la ruta `/var/log/nginx/*log` y define las etiquetas que acompañarán a los registros.

Por su parte, **`loki.source.file`** utiliza los archivos identificados para leer sus logs y enviarlos al componente `loki.write` mediante `forward_to`.

En esta configuración utilizamos las siguientes etiquetas:

* `host`: identifica el origen asociado a los logs.
* `service`: identifica el servicio que genera los registros. En este caso, NGINX.

La etiqueta `service="nginx"` nos permitirá filtrar posteriormente los registros de NGINX desde Grafana utilizando LogQL.

> **Nota:** El valor `grafana` de la etiqueta `host` es únicamente un identificador que asignamos a los registros; no cambia el lugar donde se ejecuta Alloy. Si queremos representar el servidor de origen, podemos utilizar `ubuntu` en su lugar.

### 3. Recopilar los logs del sistema Ubuntu

Para recopilar los registros del sistema utilizaremos el componente `loki.source.journal`, que permite leer las entradas almacenadas en el journal de systemd.

Agrega la siguiente configuración:

```alloy
loki.source.journal "system" {
  labels = {
    service = "system",
  }

  forward_to = [loki.write.endpoint.receiver]
}
```

En este caso, el componente `loki.source.journal` recopila las entradas del journal y les asigna la etiqueta `service="system"`.

Al igual que hicimos con los logs de NGINX, utilizamos `forward_to` para enviar los registros al componente `loki.write`, que se encargará de transmitirlos a Grafana Loki.

De esta manera, podremos diferenciar las fuentes de los registros mediante sus etiquetas y consultarlos de forma independiente desde Grafana.

### 4. Aplicar la configuración de Grafana Alloy

Para facilitar este proceso, hemos preparado el archivo de configuración de Grafana Alloy con los componentes necesarios para recopilar los logs de NGINX y del sistema Ubuntu, y enviarlos a Grafana Loki.

El archivo se encuentra disponible en el directorio `~/alloy-loki-observability/alloy/` de nuestro laboratorio.

Primero, copiaremos el archivo de configuración al directorio de Alloy, reemplazando la configuración existente:

```bash
sudo cp ~/alloy-loki-observability/alloy/config.alloy /etc/alloy/config.alloy
```

{{exec}}

Hacemos una validacion para comprobar que el archivo de configuracion este correcto:

```bash
alloy validate /etc/alloy/config.alloy
```

{{exec}}

A continuación, reiniciaremos el servicio para que Alloy cargue la nueva configuración:

```bash
sudo systemctl restart alloy
```

{{exec}}

Por último, comprobaremos que Alloy se encuentre en ejecución:

```bash
sudo systemctl status alloy --no-pager
```

{{exec}}

Si el servicio aparece como `active (running)`, significa que Alloy está en ejecución. En caso de que se presente algún error, podemos consultar los mensajes del servicio para identificar el problema:

```bash
sudo journalctl -u alloy --since "5 minutes ago" --no-pager
```

{{exec}}

Adicionalmente podemos ver el grafico de nuestra configuracion en el panel de Grafana Alloy

[Grafana Alloy Graph]({{TRAFFIC_HOST1_12345}}/graph)

## Resumen

En este paso configuramos Grafana Alloy para automatizar la recolección de logs desde dos fuentes diferentes:

* **NGINX:** mediante `local.file_match` y `loki.source.file`, leyendo los archivos de logs del servidor web.
* **Ubuntu:** mediante `loki.source.journal`, recopilando los registros almacenados en el journal de systemd.

Ambos componentes envían los registros a Grafana Loki mediante `loki.write`, permitiéndonos consultar y visualizar la información desde Grafana.

El flujo de recolección de logs queda de la siguiente manera:

```text
       Ubuntu                         NGINX
          │                             │
          ▼                             ▼
  systemd journal                 /var/log/nginx/
          │                             ▲
          ▼                             |
 loki.source.journal             local.file_match
          │                             ▼
          │                       loki.source.file
          │                             │
          └─────────────┬───────────────┘
                        ▼
                  Grafana Alloy
                        │
                        ▼
                   Grafana Loki
                        │
                        ▼
                     Grafana
```

En el siguiente paso exploraremos los logs recopilados desde Grafana, utilizando **LogQL** para realizar consultas, aplicar filtros y analizar los registros de NGINX y del sistema Ubuntu.
