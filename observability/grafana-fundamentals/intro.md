# Introducción

En este escenario aprenderás a configurar una solución básica de monitorización para un servidor Ubuntu utilizando **Grafana, Prometheus y Node Exporter**.

## ¿Qué es Grafana?

**[Grafana](https://grafana.com/oss/grafana/)** es una plataforma open source para la visualización y el análisis de datos. Permite conectarse a diferentes fuentes de datos y convertir la información recopilada en **dashboards, gráficos y paneles interactivos**.

Grafana es ampliamente utilizado en entornos de monitorización y observabilidad para analizar métricas y obtener una visión clara del estado y rendimiento de sistemas y aplicaciones.

En este escenario utilizaremos Grafana para visualizar las métricas de nuestro servidor Linux. Para ello, configuraremos **[Prometheus](https://prometheus.io/) como data source**, permitiendo que Grafana consulte las métricas recopiladas por Prometheus mediante consultas escritas en **PromQL**.

## ¿Qué es Docker?

**[Docker](https://docs.docker.com/get-started/docker-overview/)** es una plataforma que permite ejecutar aplicaciones dentro de contenedores. Los contenedores proporcionan un entorno aislado y reproducible para ejecutar aplicaciones junto con las dependencias que necesitan.

En este escenario utilizaremos Docker para ejecutar **Grafana y Prometheus**. No es necesario tener un conocimiento profundo de Docker para completar el escenario; solo utilizaremos los conceptos y comandos básicos necesarios para ejecutar y administrar estos contenedores.

**[Node Exporter](https://github.com/prometheus/node_exporter/)**, por otro lado, se instalará directamente en el servidor Ubuntu. Su función será recopilar métricas del sistema operativo y exponerlas en un formato que Prometheus pueda consultar.

## ¿Qué construiremos?

A lo largo del escenario construiremos una solución de monitorización en la que:

* **Node Exporter** recopilará y expondrá las métricas del servidor Ubuntu.
* **Prometheus** realizará un *scrape* de las métricas expuestas por Node Exporter y las almacenará.
* **Grafana** utilizará Prometheus como **data source** para consultar y visualizar las métricas.
* El usuario podrá acceder a **Grafana desde un navegador web** para explorar las métricas mediante dashboards.

El flujo principal de las métricas será:

**Node Exporter → Prometheus → Grafana → Web Browser**

## ¿Qué aprenderás?

A lo largo del escenario aprenderás a:

* Configurar **Node Exporter** para exponer las métricas del servidor Ubuntu.
* Configurar un **target en Prometheus** para recopilar las métricas de Node Exporter.
* Agregar **Prometheus como data source en Grafana**.
* Crear un panel de visualización sencillo utilizando métricas obtenidas desde Prometheus y consultas escritas en **PromQL**.
* Importar un **dashboard de la comunidad de Grafana** para visualizar las métricas del servidor.

Al finalizar el escenario, tendrás una instalación funcional de **Prometheus y Grafana** capaz de recopilar y visualizar las métricas de un servidor Linux, además de una comprensión básica de cómo estos componentes trabajan juntos en una solución de monitorización.
