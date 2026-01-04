import 'package:flutter/material.dart';

void main() => runApp(const SimApp());

const standings = {
  "ECO": 2300.0,
  "MOYEN": 3000.0,
  "HAUT STANDING": 5000.0,
};

class SimApp extends StatelessWidget {
  const SimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simulateur Promotion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F4E79)),
        useMaterial3: true,
      ),
      home: const Wizard(),
    );
  }
}

class Wizard extends StatefulWidget {
  const Wizard({super.key});

  @override
  State<Wizard> createState() => _WizardState();
}

class _WizardState extends State<Wizard> {
  int step = 0;

  // Step 1
  final terrainM2 = TextEditingController(text: "600");
  final terrainDhM2 = TextEditingController(text: "5000");

  // Step 2
  final ss1 = TextEditingController(text: "0");
  final rdc = TextEditingController(text: "0");
  final mezz = TextEditingController(text: "0");
  final List<TextEditingController> etages = [
    TextEditingController(text: "0"),
    TextEditingController(text: "0"),
    TextEditingController(text: "0"),
  ];

  // Step 3
  String standing = "MOYEN";
  final overrideCost = TextEditingController(text: "");
  bool fraisPro = true;
  final feeStudies = TextEditingController(text: "0.03");
  final feeVrd = TextEditingController(text: "0.05");
  final feeMarketing = TextEditingController(text: "0.02");
  final feeOverhead = TextEditingController(text: "0.03");
  final feeCont = TextEditingController(text: "0.04");
  final feeFin = TextEditingController(text: "0.02");

  // Step 4
  final pvApp = TextEditingController(text: "9000");
  final pvRdc = TextEditingController(text: "15000");
  bool parkingTitre = false;
  final pvParking = TextEditingController(text: "6000");
  final pvMezz = TextEditingController(text: "0");

  double _f(String s) {
    final t = s.trim().replaceAll(" ", "").replaceAll(",", ".");
    if (t.isEmpty) return 0;
    return double.tryParse(t) ?? 0;
  }

  String _dh(double v) => "${v.toStringAsFixed(0).replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => " ")} DH";
  String _m2(double v) => "${v.toStringAsFixed(2)} m²";
  String _pct(double v) => "${(v * 100).toStringAsFixed(2)}%";

  Map<String, double> compute() {
    final tM2 = _f(terrainM2.text);
    final tDh = _f(terrainDhM2.text);
    final terrainTotal = tM2 * tDh;

    final ss = _f(ss1.text);
    final rd = _f(rdc.text);
    final mz = _f(mezz.text);
    final eSum = etages.map((c) => _f(c.text)).fold(0.0, (a, b) => a + b);

    final surfaceConstruite = ss + rd + mz + eSum;

    final vendParking = ss * 0.50;
    final vendRdc = rd * 0.85;
    final vendMezz = mz * 0.50;
    final vendApp = eSum * 0.85;

    final base = standings[standing] ?? 0.0;
    final ov = _f(overrideCost.text);
    final coutM2 = ov > 0 ? ov : base;

    final coutConstruction = surfaceConstruite * coutM2;
    final coutsDirects = terrainTotal + coutConstruction;

    final p = _f(feeStudies.text) + _f(feeVrd.text) + _f(feeMarketing.text) + _f(feeOverhead.text) + _f(feeCont.text) + _f(feeFin.text);
    final frais = fraisPro ? (coutsDirects * p) : 0.0;
    final charges = coutsDirects + frais;

    final ventesApp = vendApp * _f(pvApp.text);
    final ventesRdc = vendRdc * _f(pvRdc.text);
    final ventesParking = parkingTitre ? (vendParking * _f(pvParking.text)) : 0.0;
    final ventesMezz = vendMezz * _f(pvMezz.text);
    final ventesTotales = ventesApp + ventesRdc + ventesParking + ventesMezz;

    final marge = ventesTotales > 0 ? (ventesTotales - charges) / ventesTotales : 0.0;
    final roi = charges > 0 ? (ventesTotales - charges) / charges : 0.0;

    return {
      "terrainTotal": terrainTotal,
      "surfaceConstruite": surfaceConstruite,
      "vendApp": vendApp,
      "vendRdc": vendRdc,
      "vendParking": vendParking,
      "vendMezz": vendMezz,
      "coutM2": coutM2,
      "coutConstruction": coutConstruction,
      "coutsDirects": coutsDirects,
      "fraisPro": frais,
      "charges": charges,
      "ventesApp": ventesApp,
      "ventesRdc": ventesRdc,
      "ventesParking": ventesParking,
      "ventesMezz": ventesMezz,
      "ventesTotales": ventesTotales,
      "marge": marge,
      "roi": roi,
    };
  }

  void addEtage() => setState(() => etages.add(TextEditingController(text: "0")));
  void removeEtage() {
    if (etages.length <= 1) return;
    setState(() {
      etages.removeLast().dispose();
    });
  }

  @override
  void dispose() {
    for (final c in [terrainM2, terrainDhM2, ss1, rdc, mezz, overrideCost, feeStudies, feeVrd, feeMarketing, feeOverhead, feeCont, feeFin, pvApp, pvRdc, pvParking, pvMezz, ...etages]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final res = compute();
    final msg = (res["marge"] ?? 0) < 0.20
        ? "⚠️ Marge brute faible : optimise foncier, coûts ou prix."
        : "✅ Marge brute OK.";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Simulateur Promotion — Maroc"),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: step,
        onStepContinue: () => setState(() => step = (step < 4) ? step + 1 : step),
        onStepCancel: () => setState(() => step = (step > 0) ? step - 1 : step),
        controlsBuilder: (context, details) {
          final isLast = step == 4;
          return Row(
            children: [
              ElevatedButton(
                onPressed: details.onStepContinue,
                child: Text(isLast ? "Terminer" : "Suivant"),
              ),
              const SizedBox(width: 12),
              if (step > 0)
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text("Précédent"),
                ),
            ],
          );
        },
        steps: [
          Step(
            title: const Text("Terrain"),
            content: _Card(
              children: [
                _Field(label: "Superficie terrain (m²)", controller: terrainM2),
                _Field(label: "Prix achat terrain (DH/m²)", controller: terrainDhM2),
                const SizedBox(height: 8),
                Text("Coût terrain total : ${_dh(res["terrainTotal"] ?? 0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Step(
            title: const Text("Surfaces"),
            content: _Card(
              children: [
                _Field(label: "Sous-sol 1 (m² construit) — vendable 50%", controller: ss1),
                _Field(label: "RDC (m² construit) — vendable 85%", controller: rdc),
                _Field(label: "Mezzanine (m² construit) — vendable 50%", controller: mezz),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text("Étages (vendable 85%)", style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(onPressed: addEtage, icon: const Icon(Icons.add_circle_outline)),
                    IconButton(onPressed: removeEtage, icon: const Icon(Icons.remove_circle_outline)),
                  ],
                ),
                for (int i = 0; i < etages.length; i++)
                  _Field(label: "Étage ${i + 1} (m² construit)", controller: etages[i]),
                const SizedBox(height: 8),
                Text("Surface construite : ${_m2(res["surfaceConstruite"] ?? 0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Vendable app : ${_m2(res["vendApp"] ?? 0)}"),
                Text("Vendable RDC : ${_m2(res["vendRdc"] ?? 0)}"),
                Text("Vendable parking : ${_m2(res["vendParking"] ?? 0)}"),
                Text("Vendable mezz : ${_m2(res["vendMezz"] ?? 0)}"),
              ],
            ),
          ),
          Step(
            title: const Text("Coûts"),
            content: _Card(
              children: [
                DropdownButtonFormField<String>(
                  value: standing,
                  decoration: const InputDecoration(labelText: "Standing"),
                  items: standings.keys.map((k) => DropdownMenuItem(value: k, child: Text("$k — ${standings[k]!.toStringAsFixed(0)} DH/m²"))).toList(),
                  onChanged: (v) => setState(() => standing = v ?? "MOYEN"),
                ),
                _Field(label: "Override coût (DH/m²) — optionnel", controller: overrideCost),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Activer frais PRO"),
                  value: fraisPro,
                  onChanged: (v) => setState(() => fraisPro = v),
                ),
                const SizedBox(height: 6),
                _Field(label: "Études (ex 0.03)", controller: feeStudies),
                _Field(label: "VRD (ex 0.05)", controller: feeVrd),
                _Field(label: "Marketing (ex 0.02)", controller: feeMarketing),
                _Field(label: "Frais généraux (ex 0.03)", controller: feeOverhead),
                _Field(label: "Imprévus (ex 0.04)", controller: feeCont),
                _Field(label: "Financement (ex 0.02)", controller: feeFin),
                const SizedBox(height: 8),
                Text("Coût retenu : ${_dh(res["coutM2"] ?? 0)} /m²", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Charges totales : ${_dh(res["charges"] ?? 0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Step(
            title: const Text("Ventes"),
            content: _Card(
              children: [
                _Field(label: "PV appartement (DH/m² vendable)", controller: pvApp),
                _Field(label: "PV RDC (DH/m² vendable)", controller: pvRdc),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Parking sous-sol titré ?"),
                  value: parkingTitre,
                  onChanged: (v) => setState(() => parkingTitre = v),
                ),
                _Field(label: "PV parking (DH/m² vendable)", controller: pvParking),
                _Field(label: "PV mezzanine (DH/m² vendable)", controller: pvMezz),
                const SizedBox(height: 8),
                Text("Ventes totales : ${_dh(res["ventesTotales"] ?? 0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Step(
            title: const Text("Résultats"),
            content: _Card(
              children: [
                _Kpi(label: "Ventes totales", value: _dh(res["ventesTotales"] ?? 0)),
                _Kpi(label: "Charges totales", value: _dh(res["charges"] ?? 0)),
                _Kpi(label: "Marge brute", value: _pct(res["marge"] ?? 0)),
                _Kpi(label: "ROI", value: _pct(res["roi"] ?? 0)),
                const Divider(),
                Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: children
              .map((w) => Padding(padding: const EdgeInsets.only(bottom: 10), child: w))
              .toList(),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _Field({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final String label;
  final String value;
  const _Kpi({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
