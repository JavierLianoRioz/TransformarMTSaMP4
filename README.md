# MTS to MP4 Converter

## 🚀 Cómo usar este programa

1️⃣ **Coloca tus archivos .mts** en la carpeta `input/` 📂.

2️⃣ Ejecuta el script `mtsToMp4.ps1` haciendo clic derecho sobre él y seleccionando "Ejecutar con PowerShell" 🖥️.

3️⃣ El programa buscará archivos .mts pendientes de convertir 🎥.

4️⃣ Si encuentra archivos, los convertirá a formato .mp4 y los guardará en la carpeta `output/` 🗂️.

5️⃣ ¡Listo! Tus videos estarán convertidos y listos para usar 🎉.

⚠️ **Nota:** Asegúrate de tener instalado `ffmpeg` en tu sistema y que esté en el PATH para que funcione correctamente.

## 🖥️ Uso desde la línea de comandos

1️⃣ Abre una terminal de PowerShell.

2️⃣ Navega al directorio donde se encuentra el script `mtsToMp4.ps1` usando el comando:
   ```powershell
   cd <ruta-del-directorio>
   ```
   *(Reemplaza `<ruta-del-directorio>` con la ubicación donde guardaste el script.)*

3️⃣ Ejecuta el script con el siguiente comando:
   ```powershell
   .\mtsToMp4.ps1
   ```

4️⃣ El programa procesará los archivos .mts en la carpeta `input/` y los convertirá a .mp4 en la carpeta `output/`.

5️⃣ ¡Disfruta de tus videos convertidos! 🎉

## ⚠️ Advertencia

Este script está diseñado actualmente para ejecutarse únicamente en sistemas Windows utilizando PowerShell. Si tienes ideas o sugerencias para añadir compatibilidad con otros sistemas operativos o características adicionales, ¡no dudes en enviar un Pull Request!