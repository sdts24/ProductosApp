import 'dart:io';

import 'package:flutter/material.dart';
import 'package:formvalidation/src/models/producto_model.dart';
import 'package:formvalidation/src/providers/productos_provider.dart';
import 'package:formvalidation/src/utils/utils.dart' as utils;
import 'package:image_picker/image_picker.dart';

class ProductoPage extends StatefulWidget {
  @override
  _ProductoPageState createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  ProductoModel producto = new ProductoModel();
  final productoProvider = new ProductoProvider();
  File foto;

  @override
  Widget build(BuildContext context) {
    final ProductoModel prodData = ModalRoute.of(context).settings.arguments;

    if (prodData != null) {
      producto = prodData;
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Productos'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_size_select_actual),
            onPressed: seleccionarImagen,
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: _tomarImagen,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                _mostrarFoto(),
                _crearNombre(),
                _crearPrecio(),
                _crearDisponible(),
                _crearBoton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _crearNombre() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: TextFormField(
        initialValue: producto.titulo,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
            labelText: 'Productos',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            prefixIcon: Icon(Icons.person)),
        onSaved: (valor) => producto.titulo = valor,
        validator: (value) {
          if (value.length <= 3) {
            return "Ingrese el nombre del producto";
          } else {
            return null;
          }
        },
      ),
    );
  }

  Widget _crearPrecio() {
    return TextFormField(
      initialValue: producto.valor.toString(),
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Precio',
      ),
      onSaved: (valor) => producto.valor = double.parse(valor),
      validator: (value) {
        if (utils.isNumeric(value)) {
          return null;
        } else {
          return 'Solo Numeros';
        }
      },
    );
  }

  Widget _crearDisponible() {
    return SwitchListTile(
        value: producto.disponible,
        title: Text('Disponible'),
        activeColor: Colors.deepPurple,
        onChanged: (valor) {
          setState(() {
            producto.disponible = valor;
          });
        });
  }

  Widget _crearBoton() {
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      label: Text('Guardar'),
      textColor: Colors.white,
      icon: Icon(Icons.save),
      color: Colors.deepPurple,
      onPressed: _submit,
    );
  }

  void _submit() async {
    if (!formKey.currentState.validate()) return;

    //Esto va a Disparar los metodos onSave de los TextFormField que se encuentren dentro de ese formulario.
    formKey.currentState.save();

    if ( foto != null ){
      producto.fotoUrl = await productoProvider.subirImagen(foto); 
    }

    if (producto.id == null) {
      productoProvider.crearProducto(producto);
      mostrarSnackbar('Producto Creado Correctamente');
    } else {
      productoProvider.editarProducto(producto);
      mostrarSnackbar('Producto Actualizado Correctamente');
    }

    Navigator.pop(context);
  }

  void mostrarSnackbar(String mensaje) {
    final snack = SnackBar(
      content: Container(
        alignment: Alignment.center,
        height: 50.0,
        child: Text(mensaje),
      ),
      duration: Duration(milliseconds: 1500),
      elevation: 2.0,
      backgroundColor: Colors.deepPurple,
    );

    scaffoldKey.currentState.showSnackBar(snack);
  }

  _mostrarFoto() {

    if (producto.fotoUrl != null) {
      return FadeInImage(
        image: NetworkImage( producto.fotoUrl ),
        placeholder: AssetImage('assets/original.gif'),
        height: 300.0,
        fit: BoxFit.cover,
      );
    } else {
      if (foto != null) {
        return Image.file(
          foto,
          fit: BoxFit.cover,
          height: 300.0,
        );
      }
      return Image.asset('assets/no-image.png');
    }

  }

  _procesarImagen(ImageSource tipo) async {
    foto = await ImagePicker.pickImage(
      source: tipo,
    );

    if (foto != null) {
      producto.fotoUrl = null;
    }

    setState(() {});
  }

  seleccionarImagen() {
    _procesarImagen(ImageSource.gallery);
  }

  _tomarImagen() {
    _procesarImagen(ImageSource.camera);
  }

}
