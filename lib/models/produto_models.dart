class ProdutoModel {
  int? id;
  String nome;
  int quantidade;
  double preco;

  ProdutoModel({this.id, required this.nome, required this.quantidade, required this.preco});

  // Converter um Map para um objeto Produto
  factory ProdutoModel.fromMap(Map<String, dynamic> map) {
    return ProdutoModel(
      id: map['id'],
      nome: map['nome'],
      quantidade: map['quantidade'],
      preco: map['preco'],
    );
  }

  // Converter um objeto Produto para um Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'quantidade': quantidade,
      'preco': preco,
    };
  }
}
