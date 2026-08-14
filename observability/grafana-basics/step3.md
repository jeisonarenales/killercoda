# Paso 3: Instalar y configurar Grafana

En los pasos anteriores instalamos **Node Exporter** y **Prometheus**. Ahora agregaremos **Grafana** a nuestra solución de monitorización.

Grafana será la herramienta que utilizaremos para consultar las métricas almacenadas en Prometheus y visualizarlas mediante gráficos y dashboards.

En este paso nos concentraremos únicamente en instalar Grafana y configurar **Prometheus como data source**. En el siguiente paso utilizaremos este data source para importar un dashboard de la comunidad de Grafana.

## 1. Iniciar Grafana

El servicio de Grafana ya está definido en nuestro archivo `docker-compose.yml`.

Primero, accederemos al directorio del proyecto:

```bash
cd ~/grafana-basics
```{{exec}}

Podemos revisar que el servicio `grafana` está definido en el archivo:

```bash
cat docker-compose.yml
```{{exec}}

El servicio utiliza la imagen oficial de Grafana:

```yaml
grafana:
  image: grafana/grafana:11.6
```

Grafana estará disponible en el puerto `3000` del servidor.

Para iniciar Grafana, ejecutaremos:

```bash
docker-compose up -d grafana
```{{exec}}

> **Nota:** En este escenario utilizaremos `docker-compose` para administrar los contenedores.

Podemos comprobar que el contenedor está ejecutándose:

```bash
docker-compose ps
```{{exec}}

Deberías ver los servicios `prometheus` y `grafana` con un estado similar a:

```text
NAME         STATUS
prometheus   Up
grafana      Up
```

## 2. Acceder a Grafana

Grafana está disponible en el puerto `3000`.

Puedes acceder a la interfaz web utilizando el siguiente enlace:

[http://localhost:3000]({{TRAFFIC_HOST1_3000}})

En este escenario no será necesario introducir credenciales para acceder a Grafana. El entorno está configurado para permitir el acceso anónimo con permisos de administrador.

Una vez dentro de Grafana, deberías poder visualizar la página principal de la aplicación.

## 3. ¿Qué es un data source?

Grafana puede obtener información desde diferentes fuentes de datos, como bases de datos, sistemas de monitorización y bases de datos de series temporales.

Estas fuentes de datos se configuran en Grafana como **data sources**.

En nuestro escenario utilizaremos **Prometheus como data source**:

```text
Node Exporter
      │
      │ scrape
      ▼
  Prometheus
      ▲
      │ query
      │
    Grafana
```

Prometheus se encarga de recopilar y almacenar las métricas, mientras que Grafana las consulta y las presenta mediante visualizaciones.

## 4. Agregar Prometheus como data source

Desde la interfaz de Grafana, abre el menú de configuración y selecciona:

**Connections → Data sources**

Haz clic en:

**Add new data source**

Selecciona:

**Prometheus**

Ahora debemos indicar a Grafana dónde puede encontrar nuestro servidor Prometheus.

Como ambos servicios se ejecutan dentro del mismo entorno Docker Compose, podemos utilizar el nombre del servicio `prometheus` como hostname.

En el campo **Prometheus server URL**, introduce:

```text
http://prometheus:9090
```{{copy}}

La configuración debería quedar similar a:

```text
Prometheus server URL: http://prometheus:9090
```

> **Importante:** Aquí no utilizamos `localhost:9090`. Desde el contenedor de Grafana, `localhost` hace referencia al propio contenedor de Grafana. Utilizamos `prometheus` porque corresponde al nombre del servicio definido en Docker Compose y Docker permite que los servicios se comuniquen utilizando sus nombres.

No es necesario modificar las demás opciones para este escenario.

Haz clic en:

**Save & test**

## 5. Verificar la conexión

Si la configuración es correcta, Grafana debería mostrar un mensaje indicando que el data source está funcionando correctamente.

Esto confirma que Grafana puede comunicarse con Prometheus utilizando:

```text
Grafana → http://prometheus:9090 → Prometheus
```

Ahora Grafana está preparado para consultar las métricas recopiladas por Prometheus.

## Resumen

En este paso hemos:

* Iniciado **Grafana** utilizando Docker Compose.
* Accedido a la interfaz web de Grafana.
* Aprendido qué es un **data source**.
* Configurado **Prometheus como data source** en Grafana.
* Verificado que Grafana puede comunicarse correctamente con Prometheus.

Nuestra arquitectura ahora tiene el flujo completo desde la recopilación hasta la visualización:

```text
                         scrape
Prometheus ─────────────────────────> Node Exporter
     ▲                                      │
     │                                      │
     │ query                                │
     │                                      ▼
   Grafana                            Ubuntu Linux
     ▲
     │
     │
Web Browser
```

En el siguiente paso utilizaremos el data source de Prometheus para **importar un dashboard de la comunidad de Grafana** y visualizar las métricas de nuestro servidor Linux.
