class Boleto {
  final int? id;
  final int viaje;
  final int? tarjeta;
  final int? paradaSubida;
  final String monto;
  final String fechaCompra;

  Boleto({
    this.id,
    required this.viaje,
    this.tarjeta,
    this.paradaSubida,
    required this.monto,
    required this.fechaCompra,
  });

  factory Boleto.fromJson(Map<String, dynamic> json) => Boleto(
        id: json['id'] as int?,
        viaje: json['viaje'] as int,
        tarjeta: json['tarjeta'] as int?,
        paradaSubida: json['parada_subida'] as int?,
        monto: json['monto'].toString(),
        fechaCompra: json['fecha_compra'] as String,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'viaje': viaje,
        if (tarjeta != null) 'tarjeta': tarjeta,
        if (paradaSubida != null) 'parada_subida': paradaSubida,
        'monto': monto,
        'fecha_compra': fechaCompra,
      };
}
