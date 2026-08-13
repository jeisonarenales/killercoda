# Introducción

En este escenario aprenderás a configurar una solución básica de monitorización para un servidor Ubuntu utilizando **Prometheus, Grafana y Node Exporter**.

Utilizaremos **Docker** para desplegar Prometheus y Grafana, mientras que instalaremos **Node Exporter** directamente en el servidor para recopilar métricas del sistema, como el uso de CPU, memoria, disco y red.

A lo largo del escenario aprenderás a:

* Configurar **Node Exporter** para exponer las métricas del servidor Ubuntu.
* Configurar un **target en Prometheus** para recopilar las métricas de Node Exporter.
* Agregar **Prometheus como data source en Grafana**.
* Crear un panel de visualización sencillo utilizando métricas obtenidas desde Prometheus y consultas escritas en **PromQL**.
* Importar un **dashboard de la comunidad de Grafana** para visualizar las métricas del servidor.

Al finalizar el escenario, tendrás una instalación funcional de **Prometheus y Grafana** capaz de recopilar y visualizar las métricas de un servidor Linux.
