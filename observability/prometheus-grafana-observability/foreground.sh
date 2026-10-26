#!/bin/bash
# Muestra el progreso en la terminal mientras background.sh prepara el entorno.
echo "⏳ Preparando el entorno (descargando imágenes y herramientas)..."
for _ in $(seq 1 180); do
  [ -f /tmp/.setup-done ] && break
  sleep 1
done
echo "✅ Entorno listo. Puedes comenzar."
