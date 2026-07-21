-- ============================================================
-- chatJOSE33 — Supabase Schema
-- Ejecutá esto en el SQL Editor de tu Supabase Dashboard
-- ============================================================

-- 1. Habilitar UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Tabla de mensajes
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  channel TEXT NOT NULL CHECK (channel IN ('global', 'jose')),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  nickname TEXT NOT NULL,
  text TEXT NOT NULL,
  sticker TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Tabla de baneados
CREATE TABLE banned_users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nickname TEXT NOT NULL UNIQUE,
  reason TEXT DEFAULT 'Sin razón',
  banned_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Índices para performance
CREATE INDEX idx_messages_channel_created ON chat_messages (channel, created_at DESC);
CREATE INDEX idx_banned_nickname ON banned_users (nickname);

-- 5. Habilitar Realtime para la tabla chat_messages
-- Andá a: Database > Replication > Enable replication for "chat_messages"

-- ============================================================
-- RLS (Row Level Security)
-- ============================================================

-- 5. Habilitar RLS en las tablas
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE banned_users ENABLE ROW LEVEL SECURITY;

-- 6. Políticas para chat_messages

-- Cualquiera puede leer mensajes
CREATE POLICY "chat_messages_select_all"
  ON chat_messages FOR SELECT
  USING (true);

-- Cualquiera puede insertar mensajes (público)
CREATE POLICY "chat_messages_insert_all"
  ON chat_messages FOR INSERT
  WITH CHECK (true);

-- Solo el admin puede borrar mensajes (admin = usuario con email jose@tudominio.com)
CREATE POLICY "chat_messages_delete_admin"
  ON chat_messages FOR DELETE
  USING (auth.email() = 'jose@tudominio.com');

-- 7. Políticas para banned_users

-- Cualquiera puede leer la lista de baneados
CREATE POLICY "banned_users_select_all"
  ON banned_users FOR SELECT
  USING (true);

-- Solo el admin puede banear
CREATE POLICY "banned_users_insert_admin"
  ON banned_users FOR INSERT
  WITH CHECK (auth.email() = 'jose@tudominio.com');

-- Solo el admin puede desbanear
CREATE POLICY "banned_users_delete_admin"
  ON banned_users FOR DELETE
  USING (auth.email() = 'jose@tudominio.com');

-- ============================================================
-- Crear el admin user
-- Andá a: Authentication > Users > Invite user
-- Email: jose@tudominio.com
-- Password: (la que quieras)
-- ============================================================
