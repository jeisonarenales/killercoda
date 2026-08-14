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
sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter
```{{exec}}

## 4. Verificar el servicio

Podemos comprobar que Node Exporter se está ejecutando correctamente con:

```bash
sudo systemctl status node_exporter --no-pager
```{{exec}}

Deberías ver el servicio en estado `active (running)`.

También podemos comprobar que Node Exporter está escuchando en el puerto `9100`:

```bash
sudo ss -lntp | grep 9100
```{{exec}}

## 5. Consultar las métricas

Finalmente, podemos comprobar las métricas directamente desde el endpoint HTTP de Node Exporter.

Abre el siguiente enlace en tu navegador:

[http://localhost:9100]({{TRAFFIC_HOST1_9100}})

Si Node Exporter está funcionando correctamente, encontrarás una página con una gran cantidad de métricas del servidor.

Estas métricas todavía **no están siendo recopiladas por Prometheus**. En este punto, Node Exporter simplemente las está exponiendo para que un sistema de monitorización como Prometheus pueda consultarlas.

En el siguiente paso configuraremos **Prometheus** para que realice un *scrape* de este endpoint y comience a recopilar las métricas.
````
