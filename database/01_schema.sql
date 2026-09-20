-- CondoFacil: esquema academico para um unico condominio.
-- SQLite >= 3.37 (tabelas STRICT). Ativar FKs em CADA conexao.
PRAGMA foreign_keys = ON;
BEGIN;
CREATE TABLE usuario (
 id INTEGER PRIMARY KEY,
 nome TEXT NOT NULL CHECK(length(trim(nome)) BETWEEN 2 AND 80),
 email TEXT NOT NULL COLLATE NOCASE UNIQUE CHECK(length(trim(email)) > 3),
 perfil TEXT NOT NULL CHECK(perfil IN ('morador','admin'))
) STRICT;
CREATE TABLE area_comum (
 id INTEGER PRIMARY KEY,
 nome TEXT NOT NULL UNIQUE CHECK(length(trim(nome)) BETWEEN 2 AND 80),
 capacidade INTEGER NOT NULL CHECK(capacidade > 0)
) STRICT;
CREATE TABLE reserva (
 id INTEGER PRIMARY KEY,
 usuario_id INTEGER NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
 area_id INTEGER NOT NULL REFERENCES area_comum(id) ON DELETE RESTRICT,
 data TEXT NOT NULL CHECK(length(data)=10 AND data GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
   AND date(data,'+0 days') IS NOT NULL AND date(data,'+0 days')=data),
 -- Horarios em minutos desde 00:00, no horario local do condominio.
 inicio_min INTEGER NOT NULL CHECK(inicio_min >= 480),
 fim_min INTEGER NOT NULL CHECK(fim_min <= 1320 AND fim_min > inicio_min),
 status TEXT NOT NULL DEFAULT 'ativa' CHECK(status IN ('ativa','cancelada'))
) STRICT;
CREATE TABLE aviso (
 id INTEGER PRIMARY KEY,
 autor_id INTEGER NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
 titulo TEXT NOT NULL CHECK(length(trim(titulo)) BETWEEN 1 AND 100),
 texto TEXT NOT NULL CHECK(length(trim(texto)) BETWEEN 1 AND 1500)
) STRICT;
CREATE TABLE mensagem (
 id INTEGER PRIMARY KEY,
 remetente_id INTEGER NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
 assunto TEXT NOT NULL CHECK(length(trim(assunto)) BETWEEN 1 AND 100),
 texto TEXT NOT NULL CHECK(length(trim(texto)) BETWEEN 1 AND 1500)
) STRICT;
CREATE TABLE resposta (
 id INTEGER PRIMARY KEY,
 mensagem_id INTEGER NOT NULL REFERENCES mensagem(id) ON DELETE CASCADE,
 autor_id INTEGER NOT NULL REFERENCES usuario(id) ON DELETE RESTRICT,
 texto TEXT NOT NULL CHECK(length(trim(texto)) BETWEEN 1 AND 1500)
) STRICT;
CREATE INDEX idx_reserva_agenda ON reserva(area_id,data,status,inicio_min,fim_min);
CREATE INDEX idx_reserva_usuario ON reserva(usuario_id);
CREATE INDEX idx_aviso_autor ON aviso(autor_id);
CREATE INDEX idx_mensagem_remetente ON mensagem(remetente_id);
CREATE INDEX idx_resposta_mensagem ON resposta(mensagem_id);
CREATE INDEX idx_resposta_autor ON resposta(autor_id);
-- Intervalos semiabertos: [inicio,fim). Horarios consecutivos sao permitidos.
CREATE TRIGGER reserva_sem_conflito_insert BEFORE INSERT ON reserva
WHEN NEW.status='ativa'
BEGIN
 SELECT RAISE(ABORT,'Horario indisponivel') WHERE EXISTS (
  SELECT 1 FROM reserva r WHERE r.area_id=NEW.area_id AND r.data=NEW.data
  AND r.status='ativa' AND NEW.inicio_min < r.fim_min AND NEW.fim_min > r.inicio_min
 );
END;
CREATE TRIGGER reserva_sem_conflito_update BEFORE UPDATE ON reserva
WHEN NEW.status='ativa'
BEGIN
 SELECT RAISE(ABORT,'Horario indisponivel') WHERE EXISTS (
  SELECT 1 FROM reserva r WHERE r.id<>NEW.id AND r.area_id=NEW.area_id
  AND r.data=NEW.data AND r.status='ativa'
  AND NEW.inicio_min < r.fim_min AND NEW.fim_min > r.inicio_min
 );
END;
COMMIT;
