// lib/main.dart (Projeto Passageiro)
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ==========================================
// ÁREA DE CREDENCIAIS (INSIRA SEUS DADOS AQUI)
// ==========================================
const String kFirebaseApiKey = "SUA_FIREBASE_API_KEY_AQUI";
const String kFirebaseDatabaseUrl = "https://seu-projeto.firebaseio.com/";
const String kMercadoPagoAccessToken = "TEST-SEU-ACCESS-TOKEN-MERCADO-PAGO-AQUI";
// ==========================================

void main() {
  runApp(const PassageiroApp());
}

class PassageiroApp extends StatelessWidget {
  const PassageiroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mobilidade - Passageiro',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF00E676),
      ),
      home: const TelaLoginPassageiro(),
    );
  }
}

// --- TELA DE LOGIN ---
class TelaLoginPassageiro extends StatelessWidget {
  const TelaLoginPassageiro({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final senhaController = TextEditingController();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_pin, size: 80, color: Color(0xFF00E676)),
                const SizedBox(height: 10),
                const Text(
                  'PASSAGEIRO - ACESSO',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Color(0xFF00E676),
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: senhaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const TelaPrincipalPassageiro()),
                      );
                    },
                    child: const Text('ENTRAR NO SISTEMA', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- TELA PRINCIPAL DO PASSAGEIRO ---
class TelaPrincipalPassageiro extends StatefulWidget {
  const TelaPrincipalPassageiro({super.key});

  @override
  State<TelaPrincipalPassageiro> createState() => _TelaPrincipalPassageiroState();
}

class _TelaPrincipalPassageiroState extends State<TelaPrincipalPassageiro> {
  final _destinoController = TextEditingController();
  bool _corridaSolicitada = false;

  // Função para enviar o pedido de corrida via Firebase Realtime Database REST
  Future<void> _solicitarCorridaFirebase(String destino) async {
    final url = Uri.parse('$kFirebaseDatabaseUrl/corridas.json?auth=$kFirebaseApiKey');
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          'passageiro': 'passageiro_teste@email.com',
          'destino': destino,
          'status': 'pendente',
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      if (response.statusCode == 200) {
        debugPrint("Sucesso! Resposta do Firebase: \${response.body}");
        setState(() => _corridaSolicitada = true);
      } else {
        debugPrint("Erro na requisição: \${response.statusCode} - \${response.body}");
      }
    } catch (e) {
      debugPrint("Erro ao conectar com Firebase: \$e");
    }
  }

  // Função para criar o pagamento no Mercado Pago
  Future<void> _gerarPagamentoMercadoPago(double valorTotal) async {
    final url = Uri.parse('https://api.mercadopago.com/v1/payments');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $kMercadoPagoAccessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'transaction_amount': valorTotal,
          'description': 'Corrida de Mobilidade Urbana',
          'payment_method_id': 'pix',
          'payer': {'email': 'passageiro_teste@email.com'}
        }),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        debugPrint("Pagamento gerado com sucesso: \${data['id']}");
      }
    } catch (e) {
      debugPrint("Erro ao processar pagamento Mercado Pago: \$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final tamanho = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color(0xFF1A1A1A),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.radar, size: 80, color: Color(0x3300E676)),
                  SizedBox(height: 10),
                  Text('Aguardando GPS do Passageiro...', style: TextStyle(color: Color(0xFF757575))),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212121),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00E676)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.bolt, color: Color(0xFF00E676), size: 16),
                      SizedBox(width: 6),
                      Text('Modo Passageiro', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(tamanho.width * 0.05),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3), width: 1.5),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: const Color(0xFF00E676), borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _destinoController,
                      enabled: !_corridaSolicitada,
                      decoration: InputDecoration(
                        labelText: 'Para onde vamos?',
                        prefixIcon: const Icon(Icons.location_on, color: Color(0xFF00E676)),
                        filled: true,
                        fillColor: const Color(0xFF121212),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _corridaSolicitada ? Colors.grey : const Color(0xFF00E676),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _corridaSolicitada ? null : () {
                          if (_destinoController.text.isNotEmpty) {
                            _solicitarCorridaFirebase(_destinoController.text);
                            _gerarPagamentoMercadoPago(25.00);
                          }
                        },
                        child: Text(
                          _corridaSolicitada ? 'BUSCANDO MOTORISTA...' : 'ACELERAR / CHAMAR CORRIDA',
                          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}