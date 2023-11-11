import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freegig_app/common_widgets/formatcurrency.dart';
import 'package:freegig_app/common_widgets/musicianselectionform.dart';
import 'package:freegig_app/common_widgets/searchgoogleaddress.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class CreateNewGig extends StatefulWidget {
  @override
  State<CreateNewGig> createState() => _CreateNewGigState();
}

class _CreateNewGigState extends State<CreateNewGig> {
  final TextEditingController _cacheController = TextEditingController();
  final TextEditingController _initTimeController = TextEditingController();
  final TextEditingController _finalTimeController = TextEditingController();

  final hourformat = DateFormat("HH:mm");
  final dataformat = DateFormat("dd-MM-yyyy");

  DateTime? startTime;
  DateTime? endTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Form(
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.close,
                      size: 30,
                    ))
              ],
            ),
            SizedBox(height: 12),
            Text(
              "Nova GIG",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 15),

            TextFormField(
              decoration: InputDecoration(
                labelText: 'Descrição',
                hintText: "Ex: Preciso de um tecladista",
                prefixIcon: Icon(Iconsax.keyboard),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(35)
              ], // Define o limite para 50 caracteres
            ),

            SizedBox(height: 15),
            SearchGoogleAddress(),
            SizedBox(height: 15),

            ///Hora de inicio e término
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DateTimeField(
                    controller: _initTimeController,
                    decoration: InputDecoration(
                      labelText: 'Início',
                      prefixIcon: Icon(Iconsax.clock),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                    format: hourformat,
                    onShowPicker: (context, currentValue) async {
                      final timeInicio = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                            currentValue ?? DateTime.now()),
                      );
                      setState(() {
                        startTime = DateTimeField.convert(timeInicio);
                        _initTimeController.text = startTime.toString();
                      });
                      return DateTimeField.convert(timeInicio);
                    },
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: DateTimeField(
                    controller: _finalTimeController,
                    decoration: InputDecoration(
                      labelText: 'Término',
                      prefixIcon: Icon(Iconsax.clock),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                    format: hourformat,
                    initialValue:
                        startTime, // Defina o valor inicial do campo de término com o valor do campo de início.
                    onShowPicker: (context, currentValue) async {
                      final timeTermino = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(currentValue ??
                            (startTime ??
                                DateTime
                                    .now())), // Use startTime se estiver definido.
                      );
                      setState(() {
                        endTime = DateTimeField.convert(timeTermino);
                        _finalTimeController.text = endTime.toString();
                      });
                      return DateTimeField.convert(timeTermino);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),

            ///Data e cache
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: DateTimeField(
                  decoration: InputDecoration(
                    labelText: 'Data',
                    prefixIcon: Icon(Iconsax.location),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  format: dataformat,
                  onShowPicker: (context, currentValue) async {
                    final now = DateTime.now();
                    final tomorrow = DateTime(now.year, now.month, now.day + 1);
                    return await showDatePicker(
                      context: context,
                      firstDate: tomorrow,
                      initialDate: currentValue ?? tomorrow,
                      lastDate: DateTime(2100),
                    );
                  },
                )),
                SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _cacheController,
                    onChanged: (value) {
                      setState(() {
                        _cacheController.text =
                            FormatCurrency().formatCurrency(value);
                      });
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Cachê',
                      hintText: 'Por músico',
                      prefixIcon: Icon(Iconsax.money),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            MusicianSelecttionForm(),

            SizedBox(height: 15),

            ///Mais detalhes
            TextFormField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Mais detalhes da sua GIG...\nLocal, evento, estilo de música...',
                labelText: "Detalhes",
                prefixIcon: Icon(Iconsax.device_message),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              ),
            ),

            ///Botao
            SizedBox(height: 35),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF274b99),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Text(
                  "Criar GIG",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}