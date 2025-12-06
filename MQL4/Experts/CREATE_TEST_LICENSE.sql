-- ===================================================================================
-- CREAR LICENCIA DE PRUEBA PARA SKYCORE HYDRA UNIVERSE
-- Ejecutar en Supabase SQL Editor
-- ===================================================================================

-- PASO 1: Crear cuenta MT4 con licencia
INSERT INTO public.mt4_accounts (
    user_id,
    broker_id,
    account_number,
    server_name,
    account_type,
    account_currency,
    initial_balance,
    current_balance,
    current_equity,
    robot_assigned,
    license_key,
    license_expires_at,
    is_active
)
SELECT
    (SELECT id FROM public.users WHERE email = 'test@skybot.com' LIMIT 1),
    (SELECT id FROM public.brokers WHERE broker_name = 'Exness' LIMIT 1),
    12345678,  -- ⚠️ CAMBIAR por tu número de cuenta MT4 real
    'Exness-MT4Real',
    'demo',  -- o 'live' si es cuenta real
    'USD',
    10000.00,
    10000.00,
    10000.00,
    'Hydra',
    'SKY-HYDRA-TEST-001',  -- Esta es tu license key
    NOW() + INTERVAL '1 year',  -- Expira en 1 año
    true
WHERE NOT EXISTS (
    SELECT 1 FROM public.mt4_accounts WHERE license_key = 'SKY-HYDRA-TEST-001'
);

-- ===================================================================================
-- VERIFICAR QUE SE CREÓ CORRECTAMENTE
-- ===================================================================================

SELECT
    a.id as account_id,
    a.account_number,
    a.license_key,
    a.license_expires_at,
    a.robot_assigned,
    u.email,
    u.pilot_name,
    b.planet_name
FROM public.mt4_accounts a
JOIN public.users u ON a.user_id = u.id
JOIN public.brokers b ON a.broker_id = b.id
WHERE a.license_key = 'SKY-HYDRA-TEST-001';


-- ===================================================================================
-- CREAR MÁS LICENCIAS (Opcional - para testing con múltiples cuentas)
-- ===================================================================================

-- Licencia para Raptor
INSERT INTO public.mt4_accounts (
    user_id,
    broker_id,
    account_number,
    server_name,
    account_type,
    robot_assigned,
    license_key,
    license_expires_at
)
SELECT
    (SELECT id FROM public.users WHERE email = 'test@skybot.com' LIMIT 1),
    (SELECT id FROM public.brokers WHERE broker_name = 'FBS' LIMIT 1),
    87654321,  -- Número de cuenta diferente
    'FBS-Real',
    'demo',
    'Raptor',
    'SKY-RAPTOR-TEST-001',
    NOW() + INTERVAL '1 year'
WHERE NOT EXISTS (
    SELECT 1 FROM public.mt4_accounts WHERE license_key = 'SKY-RAPTOR-TEST-001'
);

-- Licencia para Atlas
INSERT INTO public.mt4_accounts (
    user_id,
    broker_id,
    account_number,
    server_name,
    account_type,
    robot_assigned,
    license_key,
    license_expires_at
)
SELECT
    (SELECT id FROM public.users WHERE email = 'test@skybot.com' LIMIT 1),
    (SELECT id FROM public.brokers WHERE broker_name = 'IC Markets' LIMIT 1),
    11223344,
    'ICMarketsSC-MT4',
    'demo',
    'Atlas',
    'SKY-ATLAS-TEST-001',
    NOW() + INTERVAL '1 year'
WHERE NOT EXISTS (
    SELECT 1 FROM public.mt4_accounts WHERE license_key = 'SKY-ATLAS-TEST-001'
);


-- ===================================================================================
-- VALORES A USAR EN MT4
-- ===================================================================================

/*
HYDRA UNIVERSE:
input string licenseKey = "SKY-HYDRA-TEST-001";
input string userEmail = "test@skybot.com";
input long accountNumber = 12345678;  // ⚠️ Debe coincidir con tu cuenta MT4 real

RAPTOR UNIVERSE:
input string licenseKey = "SKY-RAPTOR-TEST-001";
input long accountNumber = 87654321;

ATLAS UNIVERSE:
input string licenseKey = "SKY-ATLAS-TEST-001";
input long accountNumber = 11223344;
*/


-- ===================================================================================
-- GENERAR LICENSE KEY ALEATORIA (Para producción)
-- ===================================================================================

-- Función helper para generar license keys únicas
CREATE OR REPLACE FUNCTION generate_license_key(robot_prefix VARCHAR)
RETURNS VARCHAR AS $$
BEGIN
    RETURN robot_prefix || '-' ||
           upper(substr(md5(random()::text), 1, 4)) || '-' ||
           upper(substr(md5(random()::text), 1, 4)) || '-' ||
           upper(substr(md5(random()::text), 1, 3));
END;
$$ LANGUAGE plpgsql;

-- Ejemplo de uso:
-- SELECT generate_license_key('SKY-HYDRA');
-- Resultado: SKY-HYDRA-A3F2-B8D1-C9E


-- ===================================================================================
-- REVOCAR LICENCIA (Si necesitas desactivar una)
-- ===================================================================================

-- Desactivar licencia específica
UPDATE public.mt4_accounts
SET is_active = false,
    license_expires_at = NOW()
WHERE license_key = 'SKY-HYDRA-TEST-001';


-- ===================================================================================
-- EXTENDER LICENCIA
-- ===================================================================================

-- Extender licencia por 1 mes
UPDATE public.mt4_accounts
SET license_expires_at = license_expires_at + INTERVAL '1 month'
WHERE license_key = 'SKY-HYDRA-TEST-001';

-- Extender licencia por 1 año
UPDATE public.mt4_accounts
SET license_expires_at = license_expires_at + INTERVAL '1 year'
WHERE license_key = 'SKY-HYDRA-TEST-001';
