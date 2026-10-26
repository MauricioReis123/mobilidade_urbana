// lib/main.dart (Projeto Motorista - Corrigido)
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
  runApp(const MotoristaApp());
}

class MotoristaApp extends StatelessWidget {
  const MotoristaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mobilidade - Motorista',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF00E676),
        // CORRIGIDO AQUI: Adicionado 'ColorScheme.' para evitar erro experimental
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
      ),
      home: const TelaLoginMotorista(),
    );
  }
}

// --- TELA DE LOGIN ---
class TelaLoginMotorista extends StatelessWidget {
  const TelaLoginMotorista({super.key});

  @override
  Widget build(BuildContext context) {
    final cnhController = TextEditingController();
    final senhaController = TextEditingController();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              // CORRIGIDO AQUI: Adicionado 'MainAxisAlignment.' para evitar erro experimental
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.drive_eta, size: 80, color: Color(0xFF00E676)),
                const SizedBox(height: 10),
                const Text(
                  'MOTORISTA - ACESSO',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Color(0xFF00E676),
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: cnhController,
                  decoration: InputDecoration(
                    labelText: 'Número da CNH',
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                        MaterialPageRoute(builder: (context) => const TelaPrincipalMotorista()),
                      );
                    },
                    child: const Text('ENTRAR NO PAINEL', style: TextStyle(fontWeight: FontWeight.bold)),
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

// --- TELA PRINCIPAL DO MOTORISTA ---
class TelaPrincipalMotorista extends StatefulWidget {
  const TelaPrincipalMotorista({super.key});

  @override
  State<TelaPrincipalMotorista> createState() => _TelaPrincipalMotoristaState();
}

class _TelaPrincipalMotoristaState extends State<TelaPrincipalMotorista> {
  bool _online = false;
  String? _corridaDisponivel;

  void _alternarOnline(bool valor) {
    setState(() {
      _online = valor;
      if (_online) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _online) {
            setState(() {
              _corridaDisponivel = "Destino: Av. Principal (Passageiro: Carlos)";
            });
          }
        });
      } else {
        _corridaDisponivel = null;
      }
    });
  }

  Future<void> _processarComissaoMotorista(double valorCorrida) async {
    double comissaoMotorista = valorCorrida * 0.85;
    debugPrint("Comissão calculada para o motorista: R\$ $comissaoMotorista");
  }

  @override
  Widget build(BuildContext context) {
    final tamanho = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Motorista'),
        backgroundColor: const Color(0xFF1E1E1E),
        actions: [
          Switch(
            value: _online,
            activeColor: const Color(0xFF00E676),
            onChanged: _alternarOnline,
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              // CORRIGIDO AQUI TAMBÉM
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.radar, size: 100, color: _online ? const Color(0xFF00E676) : Colors.grey.shade800),
                const SizedBox(height: 20),
                Text(
                  _online ? 'Radar Ativo: Procurando corridas no Firebase...' : 'Radar Desligado. Ative acima para rodar.',
                  style: TextStyle(fontSize: 14, color: _online ? const Color(0xFF00E676) : Colors.grey),
                ),
              ],
            ),
          ),
          if (_corridaDisponivel != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(tamanho.width * 0.05),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00E676), width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('NOVA SOLICITAÇÃO', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00E676), letterSpacing: 1.2)),
                    const SizedBox(height: 10),
                    Text(_corridaDisponivel!, style: const TextStyle(fontSize: 15)),
                    const SizedBox(height: 15),
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
                          _processarComissaoMotorista(25.00);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Corrida aceita! Comissão processada.')),
                          );
                        },
                        child: const Text('ACEITAR CORRIDA', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
