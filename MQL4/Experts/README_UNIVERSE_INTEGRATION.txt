===================================================================================
  ✅ SKYBOT UNIVERSE - INTEGRACIÓN COMPLETA
  Backend + Robots UNIVERSE Listos
===================================================================================

🎉 ¡FELICIDADES! Has completado el setup del backend SkyBot Universe.

===================================================================================
📦 LO QUE TIENES AHORA
===================================================================================

✅ BACKEND (Supabase):
   • Base de datos completa (8 tablas + 2 vistas)
   • 8 planetas configurados (Exnesstune, FBS Prime, IC Nebula, etc.)
   • Sistema de rangos (Cadet → Legend)
   • Sistema de moneda virtual (SKYTRON)
   • Triggers automáticos para stats
   • Row Level Security configurado
   • Función de validación de licencias
   • Usuario de prueba: test@skybot.com / password123

✅ MÓDULO UNIVERSE API:
   • SkyCoreUniverseAPI.mqh - Módulo de comunicación con backend
   • Funciones para validar licencia
   • Funciones para enviar heartbeats
   • Funciones para reportar trades
   • Gestión de sesiones

✅ DOCUMENTACIÓN:
   • UNIVERSE_MODIFICATION_GUIDE.txt - Guía paso a paso
   • SUPABASE_CREDENTIALS.txt - Plantilla de credenciales
   • CREATE_TEST_LICENSE.sql - Script para crear licencias
   • README_UNIVERSE_INTEGRATION.txt - Este archivo

===================================================================================
📝 ARCHIVOS CREADOS
===================================================================================

📁 MQL4/Include/
   ├── SkyCoreUniverseAPI.mqh .................... Módulo de comunicación

📁 MQL4/Experts/
   ├── UNIVERSE_MODIFICATION_GUIDE.txt ........... Guía de modificación
   ├── SUPABASE_CREDENTIALS.txt .................. Plantilla credenciales
   ├── CREATE_TEST_LICENSE.sql ................... SQL para licencias
   └── README_UNIVERSE_INTEGRATION.txt ........... Este archivo


📁 Robots a modificar:
   ├── SkyCoreHydra_UNIVERSE_v3.mq4 .............. PENDIENTE MODIFICAR
   ├── SkyCoreRaptor_UNIVERSE_v3.mq4 ............. PENDIENTE MODIFICAR
   └── SkyCoreAtlas_UNIVERSE_v3.mq4 .............. PENDIENTE MODIFICAR

===================================================================================
🚀 PRÓXIMOS PASOS (EN ORDEN)
===================================================================================

PASO 1: Obtener Credenciales de Supabase
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Ve a: https://supabase.com/dashboard
2. Selecciona proyecto "skybot-universe"
3. Settings → API
4. Copia:
   - Project URL
   - anon public key
5. Guarda los valores en SUPABASE_CREDENTIALS.txt


PASO 2: Crear Licencia de Prueba
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Abre Supabase SQL Editor
2. Abre el archivo CREATE_TEST_LICENSE.sql
3. ⚠️ IMPORTANTE: Cambia el número de cuenta (línea 17):
   account_number = 12345678,  ← Pon tu número de cuenta MT4 real
4. Ejecuta el script
5. Verifica con el SELECT al final que se creó correctamente


PASO 3: Modificar Hydra UNIVERSE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Abre SkyCoreHydra_UNIVERSE_v3.mq4 en MetaEditor
2. Sigue UNIVERSE_MODIFICATION_GUIDE.txt paso a paso
3. Reemplaza valores de ejemplo con tus credenciales reales
4. Compila y verifica que no hay errores


PASO 4: Configurar MT4 para WebRequest
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Tools → Options → Expert Advisors
2. Marca "Allow WebRequest for listed URL"
3. Agrega: https://[tu-project-id].supabase.co
4. Click OK


PASO 5: Probar Hydra UNIVERSE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Abre una cuenta demo MT4 (usa el mismo número que pusiste en la licencia)
2. Arrastra Hydra UNIVERSE al gráfico
3. Configura los inputs:
   - licenseKey = "SKY-HYDRA-TEST-001"
   - userEmail = "test@skybot.com"
   - supabaseURL = https://[tu-project].supabase.co
   - supabaseKey = [tu anon key]
4. Click OK
5. Verifica en Journal (Ctrl+T):
   ✅ "License valid! User ID: ..."
   ✅ "Session started! ID: ..."
   ✅ "Hydra UNIVERSE initialized successfully!"


PASO 6: Verificar en Supabase
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Ve a Supabase → Table Editor
2. Abre tabla "robot_sessions"
3. Deberías ver una sesión activa con:
   - robot_name: "Hydra"
   - status: "active"
   - last_heartbeat: actualizado cada 5 min
4. Cuando abras/cierres trades, verifica tabla "trades_log"


PASO 7: Replicar a Raptor y Atlas
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Una vez Hydra funcione correctamente:
1. Aplicar mismas modificaciones a Raptor UNIVERSE
2. Aplicar mismas modificaciones a Atlas UNIVERSE
3. Cambiar G_robotName a "Raptor" y "Atlas" respectivamente
4. Crear licencias de prueba para cada uno
5. Probar


===================================================================================
⚠️ TROUBLESHOOTING - ERRORES COMUNES
===================================================================================

ERROR: "WebRequest Error: 4060"
SOLUCIÓN: Habilitar WebRequest en MT4 (Tools → Options → Expert Advisors)

ERROR: "WebRequest Error: 5203"
SOLUCIÓN: Agregar URL de Supabase a lista permitida

ERROR: "LICENSE VALIDATION FAILED"
CAUSAS POSIBLES:
  • License key incorrecta
  • Account number no coincide
  • Licencia expirada
  • No hay internet
SOLUCIÓN: Verificar en Supabase tabla mt4_accounts que existe la licencia

ERROR: "Failed to start session"
CAUSA: Backend no pudo crear registro en robot_sessions
SOLUCIÓN: Verificar credenciales de Supabase y que anon key es correcta

ERROR: Heartbeat no se envía
CAUSA: G_sessionID está vacío
SOLUCIÓN: Verificar que StartSession() fue exitoso en OnInit()

ERROR: Trades no aparecen en Supabase
CAUSA: ReportTradeOpened() no se está llamando
SOLUCIÓN: Verificar que agregaste la llamada después de OrderSend()


===================================================================================
📊 VERIFICACIÓN DE FUNCIONAMIENTO
===================================================================================

✅ CHECKLIST COMPLETO:

□ Backend Supabase funcionando
□ Credenciales copiadas correctamente
□ Licencia de prueba creada en base de datos
□ Hydra UNIVERSE modificado y compilado
□ WebRequest habilitado en MT4
□ EA inicia sin error de licencia
□ Session ID visible en Journal
□ Heartbeat se envía cada 5 minutos (revisar timestamps en Supabase)
□ Trades abiertos aparecen en trades_log
□ Trades cerrados se actualizan en trades_log
□ Stats del usuario se actualizan automáticamente
□ No hay errores en Journal después de 30 minutos


===================================================================================
📈 ESTADÍSTICAS QUE SE ACTUALIZAN AUTOMÁTICAMENTE
===================================================================================

Gracias a los triggers, cuando operas con los robots UNIVERSE:

✅ Tabla users:
   - total_trades (incrementa con cada trade)
   - total_volume_lots (suma de lotes)
   - total_profit_usd (suma de ganancias)
   - win_rate (porcentaje de trades ganadores)

✅ Tabla brokers:
   - pilot_count (cuando usuario elige home planet)
   - total_volume_lots (suma de todo el planeta)

✅ Tabla robot_sessions:
   - last_heartbeat (cada 5 minutos)
   - trades_opened (contador)
   - trades_closed (contador)
   - current_profit_usd (P&L actual)


===================================================================================
🎯 SIGUIENTE FASE (Después de probar)
===================================================================================

Una vez los 3 robots UNIVERSE funcionen correctamente:

OPCIÓN A: Setup Hetzner VPS
   • Crear servidor CPX41
   • Instalar Wine + MT4
   • Migrar instancias desde EC2
   • Configurar auto-start de EAs

OPCIÓN B: Frontend Next.js
   • Crear dashboard de usuario
   • Pantalla de selección de planetas
   • Setup de cuenta MT4
   • Visualización de stats en tiempo real

OPCIÓN C: Sistema de Pagos
   • Integrar Stripe
   • Planes de suscripción
   • Generación automática de licencias
   • Dashboard de pagos


===================================================================================
📞 SOPORTE
===================================================================================

Si tienes dudas sobre las modificaciones o encuentras errores:

1. Revisar Journal de MT4 (Ctrl+T) - buscar errores específicos
2. Revisar logs en Supabase → Logs
3. Verificar tabla robot_sessions para ver última conexión
4. Verificar que todas las URLs y keys están correctas


===================================================================================
🎉 ¡ÉXITO!
===================================================================================

Cuando veas esto en el Journal de MT4:

═══════════════════════════════════════════════════════════
  🚀 SkyCore Hydra UNIVERSE v3.0
═══════════════════════════════════════════════════════════
✅ License valid! User ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
✅ Session ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
✅ Hydra UNIVERSE initialized successfully!
✅ Ready to trade
═══════════════════════════════════════════════════════════

¡Ya tienes el backend completamente funcional!

Cada trade será reportado automáticamente y podrás ver en tiempo real
las operaciones en tu dashboard de Supabase.


===================================================================================
FIN DEL README
===================================================================================

Versión: 1.0
Fecha: 2025-11-30
Platform: SkyBot Universe
Backend: Supabase (Europe West)
Robots: Hydra, Raptor, Atlas UNIVERSE v3.0
