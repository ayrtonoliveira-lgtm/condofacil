# Banco de dados do CondoFácil

Etapa acadêmica do Módulo 3 de Projeto Integrador de Tecnologia da Informação II, UFMS Digital, 2026.2.

## Modelo e escopo

Banco SQLite para um único condomínio, com seis entidades: usuario, area_comum, reserva, aviso, mensagem e resposta. Uma reserva relaciona um usuário a uma área. Uma mensagem pode receber várias respostas. Chaves estrangeiras preservam os vínculos; intervalos de reservas ativas não podem se sobrepor na mesma área e data.

Os dados serão fictícios. Este módulo executa localmente e não conecta o site do GitHub Pages ao banco. A integração por API e a autenticação são etapas futuras.

## Etapas de implementação

1. Definição do modelo e do escopo.
2. Implementação do esquema SQL e operações de manipulação.
3. Execução dos testes e documentação das evidências.
