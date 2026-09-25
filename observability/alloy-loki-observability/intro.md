# Introducción

En este escenario construiremos una solución básica de observabilidad enfocada en logs utilizando **Grafana, Grafana Loki, Grafana Alloy y NGINX**.

## ¿Qué es Grafana?

**[Grafana](https://grafana.com/oss/grafana/)** es una plataforma open source para la visualización y el análisis de datos. Permite conectarse a diferentes fuentes de datos y convertir la información recopilada en **dashboards, gráficos y paneles interactivos**.

Grafana es ampliamente utilizado en entornos de monitorización y observabilidad para analizar métricas, logs y otros datos, y obtener una visión clara del estado y comportamiento de sistemas y aplicaciones.

En este escenario utilizaremos Grafana para visualizar los logs de NGINX y de nuestro servidor Linux. Para ello, configuraremos **[Grafana Loki](https://grafana.com/oss/loki/)** como **data source**, permitiendo que Grafana consulte los logs almacenados en Loki mediante consultas escritas en **LogQL**.

## ¿Qué es Docker?

**[Docker](https://docs.docker.com/get-started/docker-overview/)** es una plataforma que permite ejecutar aplicaciones dentro de contenedores. Los contenedores proporcionan un entorno aislado y reproducible para ejecutar aplicaciones junto con las dependencias que necesitan.

En este escenario utilizaremos Docker para ejecutar **Grafana y Grafana Loki**. No es necesario tener un conocimiento profundo de Docker para completar el escenario; solo utilizaremos los conceptos y comandos básicos necesarios para ejecutar y administrar estos contenedores.

**[Grafana Alloy](https://grafana.com/oss/alloy-opentelemetry-collector/)**, por otro lado, se instalará directamente en el servidor Ubuntu. Su función será recopilar los logs de NGINX y del sistema operativo y **enviarlos** a Grafana Loki para su almacenamiento.

## ¿Qué construiremos?

A lo largo del escenario construiremos una solución de observabilidad en la que:

* **Grafana Alloy** recopilará los logs de NGINX y del servidor Ubuntu.

* **Grafana Loki** almacenará los logs.

* **Grafana** utilizará Grafana Loki como **data source** para consultar y visualizar los logs mediante consultas escritas en **LogQL**.

* El usuario podrá acceder a **Grafana desde un navegador web** para explorar los logs.

El flujo principal de los logs será:

**NGINX y logs del sistema → Grafana Alloy → Grafana Loki → Grafana → Web Browser**