import 'package:estoque_app/models/produto_models.dart';
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/produto_models.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DBHelper dbHelper = DBHelper();
  List<ProdutoModel> produtosFiltrados = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarProdutos();
  }

  void carregarProdutos() async {
    List<ProdutoModel> produtos = await dbHelper.listarProdutos();
    setState(() {
      produtosFiltrados = produtos;
    });
  }


  void mostrarDialogo({ProdutoModel? produto}) {
    TextEditingController nomeController = TextEditingController(text: produto?.nome ?? '');
    TextEditingController quantidadeController = TextEditingController(text: produto?.quantidade?.toString() ?? '');
    TextEditingController precoController = TextEditingController(text: produto?.preco?.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(produto == null ? 'Adicionar Produto' : 'Editar Produto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomeController, decoration: InputDecoration(labelText: 'Nome')),
            TextField(controller: quantidadeController, decoration: InputDecoration(labelText: 'Quantidade'), keyboardType: TextInputType.number),
            TextField(controller: precoController, decoration: InputDecoration(labelText: 'Preço'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ProdutoModel novoProduto = ProdutoModel(
                id: produto?.id,
                nome: nomeController.text,
                quantidade: int.tryParse(quantidadeController.text) ?? 0,
                preco: double.tryParse(precoController.text) ?? 0.0,
              );

              if (produto == null) {
                dbHelper.inserirProduto(novoProduto);
              } else {
                dbHelper.atualizarProduto(novoProduto);
              }

              carregarProdutos();
              Navigator.pop(context);
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void deletarProduto(int id) async {
    await dbHelper.deletarProduto(id);
    carregarProdutos();
  }

  
  void filtrarProdutos(String query) async {
  List<ProdutoModel> produtosPesquisados = await dbHelper.pesquisarProdutos(query);
  setState(() {
    produtosFiltrados = produtosPesquisados;
  });
}
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Pesquisar produto...",
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.white),
          ),
          style: TextStyle(color: Colors.white, fontSize: 18),
          onChanged: filtrarProdutos,
        ),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: produtosFiltrados.length,
        itemBuilder: (_, index) {
          ProdutoModel produto = produtosFiltrados[index];
          return ListTile(
            title: Text(produto.nome),
            subtitle: Text('Qtd: ${produto.quantidade} | R\$ ${produto.preco.toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }
}
