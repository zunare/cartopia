# Cartopia — guía paso a paso para dejarlo funcionando en tu dominio

Esto te deja el sitio funcionando de verdad, con tu propia base de datos y tu propio dominio (por ejemplo `cartopia.cl`). Vas a crear tres cuentas gratis (Supabase, GitHub y Vercel) y comprar el dominio. Sigue los pasos en orden, no te saltes ninguno.

Archivos de esta carpeta:
- `index.html` → el sitio completo (diseño, textos, toda la lógica)
- `config.js` → acá pegas las claves de tu base de datos
- `schema.sql` → el "plano" de la base de datos, lo pegas en Supabase
- esta guía

---

## Parte 1 — Crear la base de datos (Supabase)

1. Entra a **[supabase.com](https://supabase.com)** y crea una cuenta gratis (puedes usar tu correo o GitHub).
2. Clic en **"New project"**. Elige:
   - Un nombre (ej. `cartopia`)
   - Una contraseña de base de datos → **guárdala en un lugar seguro**, no la vuelves a ver
   - Región: la más cercana a Chile que te ofrezca (ej. São Paulo)
3. Espera 1-2 minutos a que el proyecto se cree.
4. En el menú de la izquierda, entra a **SQL Editor** → **New query**.
5. Abre el archivo `schema.sql` de esta carpeta, copia **desde el inicio hasta donde dice `-- ================= PARTE 2`** (sin incluir la Parte 2 todavía), pégalo en el editor y presiona **Run**. Debería decir "Success".
6. Ahora ve a **Storage** (menú izquierdo) → **New bucket**. Nombre exacto: `listing-photos`. Activa la opción **"Public bucket"**. Crea el bucket.
7. Vuelve a **SQL Editor** → **New query**, copia ahora **la Parte 2** completa de `schema.sql`, pégala y presiona **Run**.
8. Ve a **Authentication** → **Providers** → **Email**, y **apaga** la opción **"Confirm email"**. (Esto hace que el registro de vendedores funcione al instante, sin tener que confirmar el correo. Más adelante, si quieres más seguridad, puedes reactivarlo y agregar una plantilla de correo.)
9. Busca tus credenciales. Supabase cambió un poco esta pantalla, así que puede que la encuentres de dos formas distintas — cualquiera de las dos sirve:
   - **Opción rápida**: arriba del dashboard de tu proyecto hay un botón **"Connect"** — ábrelo y ahí mismo aparecen la URL y la clave, listas para copiar.
   - **Opción por menú**: ícono de engranaje (abajo a la izquierda) → **Project Settings** → **API Keys** (antes se llamaba solo "API").

   Ahí vas a necesitar dos datos:
   - **Project URL**: se ve así, con el nombre de tu proyecto en vez de "abcxyz": `https://abcxyz.supabase.co` — sin nada más al final.
   - Tu clave pública. Según cuándo hayas creado el proyecto puede aparecer con dos nombres distintos — usa la que veas:
     - **"Publishable key"**, empieza con `sb_publishable_...` (la más nueva), o
     - **"anon" / "anon public"**, una clave bien larga que empieza con `eyJ...` (la versión antigua, todavía funciona igual).

   Cualquiera de esas dos claves va en `SUPABASE_ANON_KEY` dentro de `config.js`. **Nunca copies la que dice "service_role" o "secret key"** — esa es privada, no va en el sitio.

## Parte 2 — Conectar el sitio a tu base de datos

1. Abre el archivo `config.js` con un editor de texto simple (el Bloc de notas sirve).
2. Reemplaza `https://TU-PROYECTO.supabase.co` por tu **Project URL**.
3. Reemplaza `TU-CLAVE-ANON-PUBLICA` por tu clave **anon public**.
4. Guarda el archivo.
5. Para probarlo antes de publicarlo: haz doble clic en `index.html` para abrirlo en tu navegador. Prueba registrarte como vendedor y publicar una carta de prueba. Si aparece un aviso amarillo arriba diciendo que falta conectar la base de datos, revisa que copiaste bien los datos en `config.js`.

## Parte 3 — Subir el código a GitHub

Vercel funciona mejor conectado a un repositorio de GitHub (así, cada vez que subas una versión nueva, se publica sola). No necesitas saber usar Git — todo esto se hace desde el navegador.

1. Entra a **[github.com](https://github.com)** y crea una cuenta gratis.
2. Arriba a la derecha, click en **"+"** → **"New repository"**. Nombra el repositorio `cartopia` (puede ser público o privado, cualquiera funciona con Vercel gratis) y click en **"Create repository"**.
3. En la página del repo recién creado, busca el link **"uploading an existing file"** (o el botón **"Add file"** → **"Upload files"**).
4. Arrastra ahí los 4 archivos de esta carpeta: `index.html`, `config.js`, `schema.sql` y `GUIA-PASO-A-PASO.md`.
5. Abajo escribe un mensaje corto (ej. "Primera versión") y click en **"Commit changes"**.

## Parte 4 — Publicar en Vercel

1. Entra a **[vercel.com](https://vercel.com)** y crea una cuenta gratis eligiendo **"Continue with GitHub"** (así quedan conectadas directo, sin pasos extra).
2. En el dashboard de Vercel, click **"Add New..."** → **"Project"**.
3. Busca y selecciona el repositorio `cartopia` que acabas de crear → **"Import"**.
4. Vercel te va a preguntar el "Framework Preset": déjalo tal como lo detecte (o elige "Other"/"No Framework") — no hace falta tocar nada más, este sitio no necesita "build". Click **"Deploy"**.
5. En menos de un minuto te da una dirección pública tipo `cartopia.vercel.app` — pruébala, ya está en internet.

Cuando te mande una versión nueva de algún archivo más adelante, solo tienes que entrar al repo en GitHub, abrir ese archivo, click en el ícono de lápiz (editar) o **"Upload files"** para reemplazarlo, y hacer commit — Vercel detecta el cambio y vuelve a publicar solo, en menos de un minuto.

## Parte 5 — Comprar y conectar tu dominio

1. Para un dominio `.cl`, entra a **[nic.cl](https://www.nic.cl)**. El valor de inscripción/renovación anual es de **$9.990 CLP** (según la tarifa vigente de NIC Chile — revisa el precio actualizado ahí mismo antes de pagar). Vas a necesitar tu RUT para inscribirlo.
2. Una vez comprado, entra a tu proyecto en Vercel → **Settings** → **Domains** → escribe tu dominio (ej. `cartopia.cl`) → **Add**.
3. Vercel te va a mostrar los registros DNS exactos que hay que agregar — normalmente un registro **A** apuntando a `76.76.21.21` para `cartopia.cl`, y un registro **CNAME** para `www` apuntando a la dirección que Vercel te indique en pantalla. **Usa siempre los valores que veas en tu propio panel de Vercel en ese momento**, no los de este documento ni los de otra guía, porque a veces cambian.
4. Entra al panel de NIC Chile donde administras tu dominio y agrega ahí esos mismos registros.
5. Espera unas horas (a veces hasta 24) a que el cambio se propague. Cuando esté listo, Vercel emite el certificado de seguridad (https) solo, y tu marketplace va a responder directo en `cartopia.cl`.

---

## Parte 6 (para más adelante) — Empezar a cobrar

El sitio ya viene con lo básico armado para monetizar, pero **apagado** — hoy nadie ve límites ni botones de pago. Cuando quieras activarlo:

1. En Supabase, corre la **Parte 3** de `schema.sql` (agrega las columnas de plan y destacado, más dos triggers de seguridad).
2. En `index.html`, busca la línea `var MONETIZATION_ENABLED = false;` (cerca del inicio del `<script>`) y cámbiala a `true`.
3. Con eso ya queda funcionando: los vendedores del plan gratis quedan topados a 5 publicaciones activas (lo puedes cambiar editando `FREE_LISTING_LIMIT`), y les aparece un botón "Destacar" en sus propias cartas.
4. Ese botón "Destacar" **todavía no cobra nada real** — hoy solo avisa que falta conectar un medio de pago. El paso que falta es integrar una pasarela chilena (Webpay/Transbank, Flow o MercadoPago) para que, cuando el vendedor pague, tu sitio marque esa carta como destacada o a ese vendedor como plan "pro". Eso lo podemos armar juntos cuando llegue el momento — avísame y seguimos desde ahí.

---

## Cosas que conviene saber

- **Seguridad del login**: a diferencia de la primera versión de prueba (que usaba un PIN simple), esta ya usa cuentas reales de Supabase con contraseña, que es bastante más seguro. Aun así, para lanzarlo en serio conviene más adelante reactivar "Confirm email" y revisar las políticas de contraseña en Supabase.
- **Fotos**: se comprimen automáticamente antes de subirse (quedan livianas), y se guardan en el bucket `listing-photos` de tu proyecto Supabase. El plan gratuito de Supabase incluye 1 GB de almacenamiento y una base de datos de 500 MB — para un marketplace recién empezando alcanza de sobra; si crece mucho, Supabase tiene planes pagados desde ahí.
- **Sin comisiones ni pagos en línea**: igual que en la versión anterior, el sitio solo conecta comprador y vendedor por WhatsApp — no procesa pagos ni envíos.
- Si algo no funciona, lo más común es: (a) `config.js` con datos mal copiados, (b) el bucket no se llama exactamente `listing-photos`, o (c) "Confirm email" sigue activado. Revisa esos tres primero.
