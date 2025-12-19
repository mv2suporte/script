--------------------------------------------------
-- ZABBIX + TIMESCALEDB SETUP
-- PostgreSQL 17 / TimescaleDB 2.x
--------------------------------------------------

-- 1) Criar hypertables (com migração de dados)
SELECT create_hypertable('history', 'clock',
  migrate_data => true,
  if_not_exists => true
);

SELECT create_hypertable('history_uint', 'clock',
  migrate_data => true,
  if_not_exists => true
);

SELECT create_hypertable('history_str', 'clock',
  migrate_data => true,
  if_not_exists => true
);

SELECT create_hypertable('history_text', 'clock',
  migrate_data => true,
  if_not_exists => true
);

SELECT create_hypertable('history_log', 'clock',
  migrate_data => true,
  if_not_exists => true
);

--------------------------------------------------
-- 2) Ajustar chunk interval (1 dia = 86400s)
--------------------------------------------------

SELECT set_chunk_time_interval('history', 86400);
SELECT set_chunk_time_interval('history_uint', 86400);
SELECT set_chunk_time_interval('history_str', 86400);
SELECT set_chunk_time_interval('history_text', 86400);
SELECT set_chunk_time_interval('history_log', 86400);

--------------------------------------------------
-- 3) Criar função integer_now() (OBRIGATÓRIA)
--------------------------------------------------

CREATE OR REPLACE FUNCTION public.integer_now()
RETURNS INTEGER
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT EXTRACT(EPOCH FROM now())::INTEGER;
$$;

--------------------------------------------------
-- 4) Registrar integer_now() nas hypertables
--------------------------------------------------

SELECT set_integer_now_func('history', 'public.integer_now');
SELECT set_integer_now_func('history_uint', 'public.integer_now');
SELECT set_integer_now_func('history_str', 'public.integer_now');
SELECT set_integer_now_func('history_text', 'public.integer_now');
SELECT set_integer_now_func('history_log', 'public.integer_now');

--------------------------------------------------
-- 5) Ativar compressão
--------------------------------------------------

ALTER TABLE history SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'itemid'
);

ALTER TABLE history_uint SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'itemid'
);

--------------------------------------------------
-- 6) Políticas de compressão
-- history / history_uint: 7 dias
--------------------------------------------------

SELECT add_compression_policy('history', 604800);
SELECT add_compression_policy('history_uint', 604800);

--------------------------------------------------
-- 7) Políticas de retenção (90 dias)
--------------------------------------------------

-- 90 dias = 7.776.000 segundos
SELECT add_retention_policy('history', 7776000);
SELECT add_retention_policy('history_uint', 7776000);
SELECT add_retention_policy('history_str', 7776000);
SELECT add_retention_policy('history_text', 7776000);
SELECT add_retention_policy('history_log', 7776000);

--------------------------------------------------
-- FIM
--------------------------------------------------
