-- Dados integralmente ficticios. example.invalid nao recebe email real.
PRAGMA foreign_keys=ON;
BEGIN;
INSERT INTO usuario VALUES
 (1,'Administracao Demo','admin@example.invalid','admin'),
 (2,'Marina Demo','marina@example.invalid','morador'),
 (3,'Alex Demo','alex@example.invalid','morador');
INSERT INTO area_comum VALUES (1,'Salao de festas',40),(2,'Churrasqueira',12),(3,'Quadra',20);
INSERT INTO reserva VALUES
 (1,2,1,'2026-10-10',600,720,'ativa'),
 (2,3,2,'2026-10-10',720,840,'ativa');
INSERT INTO aviso VALUES (1,1,'Manutencao preventiva','A quadra passara por vistoria demonstrativa.');
INSERT INTO mensagem VALUES (1,2,'Uso do salao','Gostaria de consultar as regras do salao.');
INSERT INTO resposta VALUES (1,1,1,'As regras estao disponiveis na tela de areas comuns.');
COMMIT;
