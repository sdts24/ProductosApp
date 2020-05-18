import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:formvalidation/src/models/producto_model.dart';
import 'package:mime_type/mime_type.dart';
import 'package:http_parser/http_parser.dart';


class ProductoProvider {
  final String _url = 'https://flutter-varios-6fdd6.firebaseio.com';

  Future<bool> crearProducto(ProductoModel producto) async {
    final url = '$_url/productos.json';

    final resp = await http.post(url, body: productoModelToJson(producto));

    final decodeData = json.decode(resp.body);

    print(decodeData);

    return true;
  }

    Future<bool> editarProducto(ProductoModel producto) async {
    final url = '$_url/productos/${ producto.id }.json';

    final resp = await http.put(url, body: productoModelToJson(producto));

    final decodeData = json.decode(resp.body);

    print(decodeData);

    return true;
  }

  Future<List<ProductoModel>> cargarProductos() async {
    final url = '$_url/productos.json';

    final resp = await http.get(url);

    final Map<String, dynamic> decodeData = json.decode(resp.body);
    final List<ProductoModel> productos = List();

    if (decodeData == null) return [];

    decodeData.forEach((id, producto) {
      final productoTemporal = ProductoModel.fromJson(producto);
      productoTemporal.id = id;

      productos.add(productoTemporal);
    });

    //print(productos);
    return productos;
  }



  Future<int> borrarProducto(String id) async {
    final url = '$_url/productos/$id.json';

    final resp = await http.delete(url);

    print(json.decode(resp.body));

    return 1;
  }


  Future<String> subirImagen( File imagen ) async {

    final url = Uri.parse('https://api.cloudinary.com/v1_1/dshtzjjsz/image/upload?upload_preset=bo4cq3sa');
    final mimeType = mime(imagen.path).split('/');


    final imageUploadRequest = http.MultipartRequest(
      'POST',
      url
    );

    final file = await http.MultipartFile.fromPath(
      'file', 
      imagen.path,
      contentType: MediaType( mimeType[0], mimeType[1] )
    );

    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();

    final respuesta = await http.Response.fromStream(streamResponse);

    if ( respuesta.statusCode != 200 && respuesta.statusCode != 201 ){
      print('Algo Salio Mall');
      print(respuesta.body);
      return null;
    }
  
    final respuestaData = json.decode(respuesta.body);
    print(respuestaData);

    return respuestaData['secure_url'];
  
  }

}
