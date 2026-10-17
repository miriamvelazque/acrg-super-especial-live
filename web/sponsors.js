// CONFIGURACION DE SPONSORS (la unica pieza que se toca para agregar, quitar o cambiar marcas).
// 1) Guardar el logo en la carpeta  web/assets/sponsors/  (PNG con fondo transparente, ideal 300 a 600 px, menos de 60 KB).
// 2) Agregar o editar una linea en top o bottom con el nombre del archivo.
// 3) Subir los cambios con git; Vercel publica solo.
window.SPONSORS = {
  // Encabezado: sponsors oficiales (maximo 4; se ven a la derecha del titulo).
  // Si un sponsor todavia no tiene logo, deja logo: '' y se muestra su nombre en texto.
  top: [
    { name: 'YPF Autosur', logo: '', url: '' },
    { name: 'BGH',         logo: '', url: '' },
    { name: 'RGA',         logo: '', url: '' },
    { name: 'Tolhuin',     logo: '', url: '' },
  ],

  // Antes del pie de pagina. size define el tamaño (y el valor comercial) del espacio:
  //   'l' = principal (grande) · 'm' = destacado (mediano) · 's' = colaborador (chico)
  bottomTitle: 'Nos acompañan',
  bottom: [
    { name: 'Sublime Design', logo: 'assets/sponsors/sublime-design.png', url: 'https://www.instagram.com/sublime.tdf/', size: 'l' },
  ],

  // Cantidad de espacios que se muestran por tamaño. Los que no tienen sponsor aparecen como "Tu marca acá"
  // (para mostrarle a los organizadores y a posibles sponsors lo que se puede vender).
  // Cuando ya esten todos vendidos, poner showPlaceholders: false y no se muestra ningun espacio vacio.
  showPlaceholders: true,
  slots: { l: 2, m: 4, s: 6 },
};
