# CondoFácil

Protótipo acadêmico para comunicação e reservas em condomínios. Projeto Integrador de Tecnologia da Informação II, UFMS Digital, 2026.2.

## Como executar

Baixe o repositório (Code > Download ZIP), extraia e abra index.html em um navegador moderno. Para usar um servidor local, execute `python -m http.server 8765` na pasta e acesse http://localhost:8765. Não há instalação de dependências: Vue 3.5.21 está incluído localmente.

## Funcionalidades

- Entrada demonstrativa como morador ou administração e cadastro fictício.
- Avisos: leitura, criação e edição pela administração.
- Reservas: consulta por área/data, bloqueio de sobreposição, confirmação e cancelamento.
- Mensagens e respostas da administração.
- Informações do condomínio, foco visível, link para pular ao conteúdo e layout responsivo.

## Organização e decisões

- index.html: documento em pt-BR, viewport, carregamento do framework e da aplicação.
- app.js: componentes Vue CondoFacilApp, LoginView e CondominiumView; estado reativo da apresentação com ref; funções de domínio e eventos.
- style.css: Flexbox, Grid e media queries em 1050, 700 e 420 px.
- vue.global.prod.js: Vue 3.5.21 (MIT); licença em VUE-LICENSE.txt.
- validacao.json: resultado de verificações técnicas automatizadas realizadas em ambiente isolado.

A adoção do Vue é incremental: ele controla a raiz, a atualização da apresentação e os eventos de clique/envio. As telas internas reaproveitam funções que retornam HTML com escape; o diálogo nativo conserva seus próprios eventos. Essa versão não converteu todos os elementos em componentes individuais.

As reservas ocorrem entre 08h e 22h. Início deve anteceder o término e estar no futuro; intervalos sobrepostos na mesma área/data são recusados, enquanto horários consecutivos são permitidos. Um campo oculto chamado id exigiu usar getAttribute('id') para identificar corretamente o formulário de aviso.

## Limitações

Nomes e dados fictícios. Login por seleção de perfil: não representa autenticação segura. Persistência apenas em localStorage, sem servidor, sincronização ou envio externo. Não usar para dados reais. Testes técnicos não equivalem a validação com moradores; não foram realizadas entrevistas ou sessões com o público-alvo.

## Evolução

API, autenticação e autorização no servidor, banco compartilhado, controle transacional de reservas e avaliação com usuários reais. Refinar a divisão dos componentes Vue.
