import 'item.dart';


class InventorySlot {

  final int id;        
   int quantity; 

  final Item item;

  InventorySlot({
    required this.id,
    required this.quantity,
    required this.item,
  });

  factory InventorySlot.fromJson(Map<String, dynamic> json) {

    return InventorySlot(

      id: json['id'],
      quantity: json['quantity'],


      item: Item.fromJson(json['item']),
    );
  }
}