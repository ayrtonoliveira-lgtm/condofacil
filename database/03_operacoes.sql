-- Executar uma vez em banco novo apos 01_schema.sql e 02_dados.sql.
PRAGMA foreign_keys=ON;
BEGIN;
-- INSERT: reserva consecutiva, sem sobreposicao (12h-14h).
INSERT INTO reserva VALUES (3,3,1,'2026-10-10',720,840,'ativa');
-- UPDATE: cancelamento preserva o historico e libera o horario.
UPDATE reserva SET status='cancelada' WHERE id=2;
-- DELETE: remocao controlada de mensagem de teste; resposta sai por CASCADE.
INSERT INTO mensagem VALUES (99,3,'Teste descartavel','Mensagem para demonstrar remocao.');
INSERT INTO resposta VALUES (99,99,1,'Resposta descartavel.');
DELETE FROM mensagem WHERE id=99;
COMMIT;
-- SELECT com JOIN: agenda ativa legivel.
SELECT r.id,u.nome AS morador,a.nome AS area,r.data,
 printf('%02d:%02d',r.inicio_min/60,r.inicio_min%60) AS inicio,
 printf('%02d:%02d',r.fim_min/60,r.fim_min%60) AS fim
FROM reserva r JOIN usuario u ON u.id=r.usuario_id
JOIN area_comum a ON a.id=r.area_id
WHERE r.status='ativa' ORDER BY r.data,r.inicio_min,r.id;
-- LEFT JOIN e agregacao: inclui areas sem reservas ativas.
SELECT a.nome,COUNT(r.id) AS reservas_ativas
FROM area_comum a LEFT JOIN reserva r ON r.area_id=a.id AND r.status='ativa'
GROUP BY a.id,a.nome ORDER BY a.id;
