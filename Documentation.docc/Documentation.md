# ``AudioModifier``

Aplicativo macOS em SwiftUI para selecionar arquivos de áudio, visualizar informações técnicas e editar metadados como título, artista, álbum, gênero, faixa, comentário e capa.

## Visão Geral

O projeto usa uma organização MVVM simples:

- `View`: telas e componentes SwiftUI.
- `ViewModel`: estado da tela e coordenação de ações do usuário.
- `Model`: estruturas de dados, formatadores e regras auxiliares.
- `Model/Service`: integração com AVFoundation, SPFKMetadata e sistema de arquivos.

## Fluxo Principal

1. `SelectView` abre um `fileImporter` para escolher um arquivo de áudio.
2. `SelectViewModel` recebe a URL e chama `AudioSelectService`.
3. `AudioSelectService` combina dados técnicos via AVFoundation com metadados via SPFKMetadata.
4. A tela mostra dados técnicos e tags encontradas.
5. O botão de lápis abre `EditMetadataView`.
6. `EditMetadataViewModel` mantém um rascunho editável em `EditableAudioMetadata`.
7. Ao salvar, o usuário escolhe entre alterar o original ou criar uma cópia modificada.

## Arquivos-Chave

- ``AudioFile``
- ``AudioMetadata``
- ``EditableAudioMetadata``
- ``AudioSelectService``
- ``SPFKMetadataService``
- ``SelectViewModel``
- ``EditMetadataViewModel``

## macOS Sandbox

O app usa seletores de arquivo. Para ler e escrever arquivos escolhidos pelo usuário, configure o target em `Signing & Capabilities > App Sandbox > File Access`.

Para criar cópias modificadas com `NSSavePanel`, use `User Selected File: Read/Write`.

## Escopo

Este catálogo documenta apenas o `AudioModifier`. As dependências continuam no workspace e podem aparecer no navegador geral de documentação do Xcode, mas esta entrada é o ponto de consulta focado no app.
