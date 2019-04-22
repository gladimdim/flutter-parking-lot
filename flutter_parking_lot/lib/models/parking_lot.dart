import 'package:tuple/tuple.dart';

const PAYMENT_PER_HOUR = 15.0;
const HOUR_MS = 3600000;
const BUFFER_TIME = 900000;
const ALLOWED_DIFF = PAYMENT_PER_HOUR / 4;

class Parking {
  final List<Client> clients = [];
  final List<Tuple3<Client, double, DateTime>> payedClients = [];
  final List<Client> paymentsHistory = [];
  final int capacity;

  Parking({this.capacity});

  void addClient(Client client) {
    if (isBusy) {
      throw ParkingLotFull(
          "Parking lot is full. All $capacity are occupired.");
    }

    client.clockIn();
    clients.add(client);
  }

  void acceptPayment(Client client, double amount) {
    var existingIndex = _findClientInPayments(client);
    if (existingIndex >= 0) {
      var clientTuple = payedClients[existingIndex].withItem2(amount);
      payedClients[existingIndex] = clientTuple;
    } else {
      payedClients.add(Tuple3(client, amount, DateTime.now()));
    }
  }

  void clockOutClient(Client client) {
    var clientIndex = payedClients.indexWhere((tuple) => tuple.item1 == client);
    if (clientIndex < 0) {
      throw NotPayed(
              "Client ${client.licenseNumber} did not pay ${calculatePayment(client)}");
    }

    var tuple = payedClients[clientIndex];

    double payed = tuple.item2;
    double estimate = calculatePayment(tuple.item1);

    if (payed - estimate <= ALLOWED_DIFF) {
      _letClientOut(tuple.item1);
    } else {
      throw NotPayed(
          "Client ${client.licenseNumber} need to pay more: ${estimate - payed}"
      );
    }
  }

  double calculatePayment(Client client) {
    var now = DateTime.now();
    var timeSpent = now.difference(client.clockedInTime).inMinutes;
    return timeSpent / 60 * PAYMENT_PER_HOUR;
  }

  int _findClientInPayments(Client client) {
    return payedClients.indexWhere((tuple) => tuple.item1 == client);
  }

  bool get isBusy {
    return clients.length > capacity;
  }

  void clockInClient(Client client) {
    client.clockedInTime = DateTime.now();
  }

  void _letClientOut(Client client) {
    this.payedClients.remove(client);
    this.clients.remove(client);
  }
}

class Client {
  final String licenseNumber;
  DateTime clockedInTime;

  void clockIn() {
    this.clockedInTime = DateTime.now();
  }

  Client({this.licenseNumber});
}

class ParkingLotFull implements Exception {
  String msg;

  ParkingLotFull(this.msg);
}

class NotPayed implements Exception {
  final String msg;

  String toString() {
    return msg;
  }
  NotPayed(this.msg);
}
