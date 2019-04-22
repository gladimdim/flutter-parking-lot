import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_parking_lot/models/parking_lot.dart';

class ParkingLot extends StatefulWidget {
  final int capacity;

  ParkingLot({@required this.capacity});

  @override
  _ParkingLotState createState() => _ParkingLotState();
}

class _ParkingLotState extends State<ParkingLot> {
  Parking lot;

  @override
  void initState() {
    lot = Parking(capacity: widget.capacity);
    super.initState();
    lot.addClient(Client(licenseNumber: "111"));
    lot.addClient(Client(licenseNumber: "222"));
    lot.addClient(Client(licenseNumber: "333"));
    lot.addClient(Client(licenseNumber: "444"));
    lot.addClient(Client(licenseNumber: "555"));
    lot.addClient(Client(licenseNumber: "666"));
    lot.addClient(Client(licenseNumber: "777"));
  }

  @override
  Widget build(BuildContext context) {
    return _buildParkingView();
  }

  void onAddClient() {
    Random random = Random();
    var client = new Client(licenseNumber: random.nextInt(1000).toString());
    setState(() {
      lot.addClient(client);
    });
  }

  GridView _buildParkingView() {
    return GridView.count(
        crossAxisCount: 4,
        children: List.generate(lot.capacity, (index) {
          if (lot.clients.length > index) {
            return SizedBox(
              child: ParkingSpot(
                client: lot.clients[index],
                estimator: lot.calculatePayment,
                payForClient: (client) => lot.acceptPayment(client, 10),
                onClientExit: (client) => lot.clockOutClient(client),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildEmptySpot(index, onAddClient),
            );
          }
        }));
  }

  Container _buildEmptySpot(int index, Function addClient) {
    return Container(
      child: Column(
        children: <Widget>[
          Text("Vacant $index"),
          RaisedButton(
            child: Text("Add"),
            onPressed: addClient,
          )
        ],
      ),
      decoration: BoxDecoration(
        border: Border.all(
          width: 3,
          color: Colors.green,
        ),
      ),
    );
  }
}

class ParkingSpot extends StatelessWidget {
  final Client client;
  final Function estimator;
  final Function(Client) payForClient;
  final Function(Client) onClientExit;

  ParkingSpot({
    @required this.client,
    @required this.estimator,
    @required this.payForClient,
    @required this.onClientExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(client.licenseNumber),
          Text(
              "Spent: ${DateTime.now().difference(client.clockedInTime).inMinutes} mins"),
          Text("Due: ${estimator(client)}"),
          RaisedButton(
            child: Text("Add \$5"),
            color: Colors.green,
            onPressed: () => payForClient(client),
          ),
          RaisedButton(
            child: Text("Get out"),
            color: Colors.yellow,
            onPressed: () => onClientExit(client),
          )
        ],
      ),
    );
  }
}
