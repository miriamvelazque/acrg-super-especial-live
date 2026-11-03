// Pie de pagina compartido. Completa CONTACTO (whatsapp, facebook, instagram, email): lo que quede vacio no se muestra.
(() => {
  const C = { whatsapp: '', facebook: 'acrg.tierradelfuego.1', facebookLabel: 'Acrg Tierra del Fuego', instagram: '@acrgtierradel', email: '', org: 'Automóvil Club Río Grande.', year: 2026, legal: 'legal.html',
    linkedin: 'https://www.linkedin.com/in/miriam-alicia-velazque' };
  const st = 'fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"';
  const I = {
    wa: `<svg width="22" height="22" viewBox="0 0 24 24" ${st}><path d="M12 2a10 10 0 0 0-8.6 15L2 22l5.2-1.4A10 10 0 1 0 12 2z"/><path d="M8.5 9c.5 3 3 5.5 6 6l1.5-1.5-2-1-1 .8c-1-.5-2-1.500-2.500-2.500l.8-1-1-2z"/></svg>`,
    ig: `<svg width="22" height="22" viewBox="0 0 24 24" ${st}><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.500" cy="6.500" r=".6"/></svg>`,
    fb: `<svg width="22" height="22" viewBox="0 0 24 24" ${st}><path d="M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z"/></svg>`,
    ml: `<svg width="22" height="22" viewBox="0 0 24 24" ${st}><rect x="3" y="5" width="18" height="14" rx="2"/><path d="m3 7 9 6 9-6"/></svg>`,
    li: `<svg width="24" height="24" viewBox="0 0 24 24" aria-hidden="true"><rect width="24" height="24" rx="4" fill="#0A66C2"/><text x="12" y="17.500" text-anchor="middle" font-size="14" font-weight="700" fill="#fff" font-family="Arial,sans-serif">in</text></svg>`,
    logo: `<img src="assets/logo-acrg.jpg" alt="Automóvil Club Río Grande" width="56" height="56" style="height:3.5rem;width:3.5rem;border-radius:50%;background:#fff;object-fit:contain;display:block">` };
  const digits = s => s.replace(/\D/g, '');
  const contact = [
    C.facebook && `<a href="https://www.facebook.com/${C.facebook}" target="_blank" rel="noopener noreferrer">${I.fb}<span>${C.facebookLabel || C.facebook}</span></a>`,
    C.whatsapp && `<a href="https://wa.me/${digits(C.whatsapp)}" target="_blank" rel="noopener noreferrer">${I.wa}<span>${C.whatsapp}</span></a>`,
    C.instagram && `<a href="https://instagram.com/${C.instagram.replace('@','')}" target="_blank" rel="noopener noreferrer">${I.ig}<span>${C.instagram.replace('@','')}</span></a>`,
    C.email && `<a href="mailto:${C.email}">${I.ml}<span>${C.email}</span></a>`].filter(Boolean).join('');
  const css = `#rf-footer{margin-top:3rem;background:#0f0f13;border-top:3px solid #6EC7FF;color:#b4b4bd;font-family:Barlow,system-ui,sans-serif;font-size:.95rem}
#rf-footer .in{max-width:1100px;margin:0 auto;padding:2rem 1rem 1.2rem;display:flex;flex-direction:column;align-items:center;gap:1.1rem;text-align:center}
#rf-footer a{color:inherit;text-decoration:none;display:inline-flex;align-items:center;gap:.5rem}#rf-footer a:hover{color:#6EC7FF}
#rf-footer .brand{display:flex;align-items:center;gap:.8rem;color:#fff}#rf-footer .brand b{font:normal 800 2rem/1 'Barlow Condensed','Arial Narrow',sans-serif;text-transform:uppercase;letter-spacing:.01em}
#rf-footer .row{display:flex;flex-wrap:wrap;justify-content:center;gap:.6rem 1.8rem}
#rf-footer hr{width:100%;border:0;border-top:1px solid #2a2a31;margin:.3rem 0}
#rf-footer .sep{opacity:.4}`;
  const f = document.createElement('footer'); f.id = 'rf-footer';
  f.innerHTML = `<style>${css}</style><div class="in">
    <div class="brand">${I.logo}<div style="text-align:left;font-size:.95rem;color:#6EC7FF">Live Timing</div></div>
    ${contact ? `<div class="row">${contact}</div>` : ''}
    <nav class="row" aria-label="Información legal"><a href="${C.legal}#aviso">Aviso sobre resultados</a><a href="${C.legal}#terminos">Términos de uso</a><a href="${C.legal}#privacidad">Privacidad</a><a href="${C.legal}#cookies">Cookies</a></nav>
    <hr>
    <div class="row" style="align-items:center"><span>© ${C.year} Súper Especial — ${C.org} Todos los derechos reservados.</span><span class="sep" aria-hidden="true">|</span>
      <span style="display:inline-flex;align-items:center;gap:.6rem">Diseñado y desarrollado por Miriam Velazque - (+54) 9 2964 509725 <a href="${C.linkedin}" target="_blank" rel="noopener noreferrer" aria-label="LinkedIn de Miriam Velazque">${I.li}</a></span></div></div>`;
  document.body.appendChild(f);
})();
