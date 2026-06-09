//
//  MetadataSaveDestination.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 09/06/26.
//

import Foundation

/// Define onde uma edição de metadados deve ser gravada.
///
/// A opção de cópia é importante porque alterar metadados reescreve partes do
/// arquivo. Trabalhar em uma cópia reduz o risco de perder o arquivo original se
/// a biblioteca de escrita ou o sistema de arquivos falhar.
enum MetadataSaveDestination: Hashable {
    /// Grava diretamente no arquivo escolhido pelo usuário.
    case original

    /// Cria uma cópia no URL informado e grava os metadados nessa cópia.
    case copy(URL)
}
