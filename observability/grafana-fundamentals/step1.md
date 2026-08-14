# Paso 1: Instalar Node Exporter

Antes de configurar Prometheus y Grafana, necesitamos una fuente de métricas. En este escenario utilizaremos **Node Exporter**, un exporter del ecosistema de Prometheus diseñado para recopilar métricas del sistema operativo y exponerlas en un formato que Prometheus pueda consultar.

## ¿Qué es Node Exporter?

**Node Exporter** es un exporter de Prometheus que recopila métricas relacionadas con el hardware y el sistema operativo de sistemas basados en Unix/Linux.

Entre las métricas que puede exponer se encuentran:

* Uso de CPU.
* Uso y disponibilidad de memoria.
* Espacio disponible en los sistemas de archivos.
* Actividad de los discos.
* Tráfico y estadísticas de las interfaces de red.
* Tiempo que lleva ejecutándose el sistema (*uptime*).

Node Exporter expone estas métricas a través de un endpoint HTTP, normalmente en el **puerto 9100**. Posteriormente, Prometheus podrá consultar este endpoint periódicamente y almacenar las métricas.

> **Nota:** En este paso únicamente instalaremos y configuraremos Node Exporter. En el siguiente paso configuraremos Prometheus para que recopile las métricas expuestas por Node Exporter.

## 1. Descargar Node Exporter

Primero descargaremos Node Exporter desde las versiones oficiales disponibles en el proyecto de Prometheus.

En este escenario utilizaremos la versión `1.12.1`:

```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.12.1/node_exporter-1.12.1.linux-amd64.tar.gz
```{{exec}}

## 2. Instalar Node Exporter

A continuación, extraeremos el archivo descargado y copiaremos el binario de Node Exporter a `/usr/local/bin`.

```bash
tar -xvf node_exporter-1.12.1.linux-amd64.tar.gz && \
cd node_exporter-1.12.1.linux-amd64 && \
sudo cp node_exporter /usr/local/bin/
```{{exec}}

Podemos comprobar que el binario se encuentra disponible ejecutando:

```bash
node_exporter --version
```{{exec}}

Deberías obtener una salida similar a:

```text
node_exporter, version 1.12.1
```

## 3. Crear un servicio de systemd

Para administrar Node Exporter como un servicio del sistema, crearemos un usuario dedicado y un servicio de `systemd`.

Primero, crearemos el usuario `node_exporter`:

```bash
sudo useradd -rs /bin/false node_exporter
```{{exec}}

Ahora crearemos el archivo de servicio:

```bash
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<'EOF'
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF
```{{exec}}

Recargaremos la configuración de `systemd` y habilitaremos e iniciaremos el servicio:

```bash
sudo systemctl daemon-reload && \
sudo systemctl enable --now node_exporter
```{{exec}}

El comando anterior realiza dos acciones:

- `enable`: configura el servicio para que se inicie automáticamente durante el arranque del sistema.
- `--now`: inicia el servicio inmediatamente, sin necesidad de reiniciar el servidor.

## 4. Verificar el servicio

Comprobaremos que Node Exporter se está ejecutando correctamente:

```bash
sudo systemctl status node_exporter --no-pager
```{{exec}}

Deberías ver el servicio en estado:

```text
Active: active (running)
```

También podemos verificar que Node Exporter está escuchando en el puerto `9100`:

```bash
sudo ss -lntp | grep 9100
```{{exec}}

Deberías obtener una salida indicando que existe un proceso escuchando en el puerto `9100`.

## 5. Consultar las métricas

Finalmente, podemos consultar directamente el endpoint de métricas de Node Exporter:

```bash
curl -s http://localhost:9100/metrics | head
```{{exec}}

Si todo está funcionando correctamente, veremos algunas de las métricas expuestas por Node Exporter.

Node Exporter también proporciona una interfaz web en el puerto `9100`. Puedes acceder a ella desde el siguiente enlace:

[http://localhost:9100/metrics]({{TRAFFIC_HOST1_9100}}/metrics)

Si ves la página de Node Exporter y una lista de métricas, la instalación se ha completado correctamente.

> **Importante:** En este punto, Node Exporter únicamente está **exponiendo** las métricas del servidor. Todavía no tenemos ningún componente recopilándolas. En el siguiente paso configuraremos **Prometheus** para que realice un *scrape* de este endpoint y almacene las métricas.

## Resumen

En este paso hemos:

- Instalado el binario de **Node Exporter**.
- Creado un usuario dedicado para ejecutar el servicio.
- Configurado Node Exporter como un servicio de `systemd`.
- Habilitado el servicio para que se inicie automáticamente.
- Verificado que Node Exporter está ejecutándose y escuchando en el puerto `9100`.
- Consultado las métricas expuestas por Node Exporter.

En el siguiente paso configuraremos **Prometheus** y agregaremos Node Exporter como un **target** para comenzar a recopilar estas métricas.
