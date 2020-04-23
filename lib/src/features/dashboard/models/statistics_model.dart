// To parse this JSON data, do
//
//     final statisticsModel = statisticsModelFromJson(jsonString);

import 'dart:convert';

StatisticsModel statisticsModelFromJson(String str) =>
    StatisticsModel.fromJson(json.decode(str));

String statisticsModelToJson(StatisticsModel data) =>
    json.encode(data.toJson());

class StatisticsModel {
  Map<String, Centros> centrosAislamiento;
  Map<String, Centros> centrosDiagnostico;
  Casos casos;

  StatisticsModel({
    this.centrosAislamiento,
    this.centrosDiagnostico,
    this.casos,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) =>
      StatisticsModel(
        centrosAislamiento: Map.from(json["centros_aislamiento"])
            .map((k, v) => MapEntry<String, Centros>(k, Centros.fromJson(v))),
        centrosDiagnostico: Map.from(json["centros_diagnostico"])
            .map((k, v) => MapEntry<String, Centros>(k, Centros.fromJson(v))),
        casos: Casos.fromJson(json["casos"]),
      );

  Map<String, dynamic> toJson() => {
        "centros_aislamiento": Map.from(centrosAislamiento)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "centros_diagnostico": Map.from(centrosDiagnostico)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "casos": casos.toJson(),
      };

  //
  Map<String, int> resume = {
    "Diagnosticados": 0,
    "Activos": 0,
    "Muertes": 0,
    "Evacuados": 0,
    "Recuperados": 0,
  };

  Map<String, int> contagios = {
    'importado': 0,
    'introducido': 0,
    'autoctono': 0,
    'desconocido': 0
  };

  Map<String, int> sex = {"Mujeres": 0, "Hombres": 0};

  Map<String, int> ages = {
    '0-18': 0,
    '19-40': 0,
    '41-60': 0,
    '61 o más': 0,
    'Desconocido': 0
  };

  void buildReports() {
    this.casos.dias.forEach((str, day) {
      if (day.diagnosticados != null) {
        if (day.diagnosticados != null) {
          this.resume['Diagnosticados'] += day.diagnosticados.length;

          day.diagnosticados.forEach((d) {
            // modos de contagios
            if (d.contagio == Contagio.IMPORTADO) {
              this.contagios['importado']++;
            } else if (d.contagio == Contagio.INTRODUCIDO) {
              this.contagios['introducido']++;
            } else if (d.contagio == Contagio.AUTOCTONO) {
              this.contagios['autoctono']++;
            } else if (d.contagio == Contagio.DESCONOCIDO) {
              this.contagios['desconocido']++;
            }

            // por sexo
            if (d.sexo == Sexo.MUJER) {
              this.sex['Mujeres']++;
            } else if (d.sexo == Sexo.HOMBRE) {
              this.sex['Hombres']++;
            }

            // por rango de edades
            // if (d.edad >= 0 && d.edad <= 18) {
            //   this.ages['0-18']++;
            // } else if (d.edad >= 19 && d.edad <= 40) {
            //   this.ages['19-40']++;
            // } else if (d.edad >= 41 && d.edad <= 60) {
            //   this.ages['41-60']++;
            // } else if (d.edad >= 61) {
            //   this.ages['61 o más']++;
            // } else {
            //   this.ages['Desconocido']++;
            // }

            //
          });
        }

        if (day.muertesNumero != null) {
          this.resume['Muertes'] += day.muertesNumero;
        }

        if (day.evacuadosNumero != null) {
          this.resume['Evacuados'] += day.evacuadosNumero;
        }

        if (day.evacuadosNumero != null) {
          this.resume['Recuperados'] += day.recuperadosNumero;
        }

       this.resume['Activos'] = this.resume['Diagnosticados'] - this.resume['Muertes'] - this.resume['Evacuados'];
      }
    });
  }

}

class Casos {
  Map<String, Dia> dias;

  Casos({
    this.dias,
  });

  factory Casos.fromJson(Map<String, dynamic> json) => Casos(
        dias: Map.from(json["dias"])
            .map((k, v) => MapEntry<String, Dia>(k, Dia.fromJson(v))),
      );

  Map<String, dynamic> toJson() => {
        "dias": Map.from(dias)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
      };
}

class Dia {
  String fecha;
  List<Diagnosticado> diagnosticados;
  int sujetosRiesgo;
  int gravesNumero;
  List<String> gravesId;
  int muertesNumero;
  List<String> muertesId;
  int evacuadosNumero;
  List<String> evacuadosId;

  Dia({
    this.fecha,
    this.diagnosticados,
    this.sujetosRiesgo,
    this.gravesNumero,
    this.gravesId,
    this.muertesNumero,
    this.muertesId,
    this.evacuadosNumero,
    this.evacuadosId,
  });

  factory Dia.fromJson(Map<String, dynamic> json) => Dia(
        fecha: json["fecha"],
        diagnosticados: json["diagnosticados"] == null
            ? null
            : List<Diagnosticado>.from(
                json["diagnosticados"].map((x) => Diagnosticado.fromJson(x))),
        sujetosRiesgo:
            json["sujetos_riesgo"] == null ? null : json["sujetos_riesgo"],
        gravesNumero:
            json["graves_numero"] == null ? null : json["graves_numero"],
        gravesId: json["graves_id"] == null
            ? null
            : List<String>.from(json["graves_id"].map((x) => x)),
        muertesNumero:
            json["muertes_numero"] == null ? null : json["muertes_numero"],
        muertesId: json["muertes_id"] == null
            ? null
            : List<String>.from(json["muertes_id"].map((x) => x)),
        evacuadosNumero:
            json["evacuados_numero"] == null ? null : json["evacuados_numero"],
        evacuadosId: json["evacuados_id"] == null
            ? null
            : List<String>.from(json["evacuados_id"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "fecha": fecha,
        "diagnosticados": diagnosticados == null
            ? null
            : List<dynamic>.from(diagnosticados.map((x) => x.toJson())),
        "sujetos_riesgo": sujetosRiesgo == null ? null : sujetosRiesgo,
        "graves_numero": gravesNumero == null ? null : gravesNumero,
        "graves_id": gravesId == null
            ? null
            : List<dynamic>.from(gravesId.map((x) => x)),
        "muertes_numero": muertesNumero == null ? null : muertesNumero,
        "muertes_id": muertesId == null
            ? null
            : List<dynamic>.from(muertesId.map((x) => x)),
        "evacuados_numero": evacuadosNumero == null ? null : evacuadosNumero,
        "evacuados_id": evacuadosId == null
            ? null
            : List<dynamic>.from(evacuadosId.map((x) => x)),
      };
}

class Diagnosticado {
  String id;
  String pais;
  int edad;
  Sexo sexo;
  String arriboACubaFoco;
  String consultaMedico;
  String municipioDeteccin;
  String provinciaDeteccin;
  String dpacodeMunicipioDeteccion;
  String dpacodeProvinciaDeteccion;
  List<String> provinciasVisitadas;
  List<String> dpacodeProvinciasVisitadas;
  Contagio contagio;
  int contactoFocal;
  String centroAislamiento;
  CentroDiagnostico centroDiagnostico;
  List<String> posibleProcedenciaContagio;
  int sujetosRiesgo;

  Diagnosticado({
    this.id,
    this.pais,
    this.edad,
    this.sexo,
    this.arriboACubaFoco,
    this.consultaMedico,
    this.municipioDeteccin,
    this.provinciaDeteccin,
    this.dpacodeMunicipioDeteccion,
    this.dpacodeProvinciaDeteccion,
    this.provinciasVisitadas,
    this.dpacodeProvinciasVisitadas,
    this.contagio,
    this.contactoFocal,
    this.centroAislamiento,
    this.centroDiagnostico,
    this.posibleProcedenciaContagio,
    this.sujetosRiesgo,
  });

  factory Diagnosticado.fromJson(Map<String, dynamic> json) => Diagnosticado(
        id: json["id"],
        pais: json["pais"],
        edad: json["edad"] == null ? null : json["edad"],
        sexo: sexoValues.map[json["sexo"]],
        arriboACubaFoco: json["arribo_a_cuba_foco"] == null
            ? null
            : json["arribo_a_cuba_foco"],
        consultaMedico:
            json["consulta_medico"] == null ? null : json["consulta_medico"],
        municipioDeteccin: json["municipio_detección"] == null
            ? null
            : json["municipio_detección"],
        provinciaDeteccin: json["provincia_detección"] == null
            ? null
            : json["provincia_detección"],
        dpacodeMunicipioDeteccion: json["dpacode_municipio_deteccion"],
        dpacodeProvinciaDeteccion: json["dpacode_provincia_deteccion"],
        provinciasVisitadas:
            List<String>.from(json["provincias_visitadas"].map((x) => x)),
        dpacodeProvinciasVisitadas: List<String>.from(
            json["dpacode_provincias_visitadas"].map((x) => x)),
        contagio: contagioValues.map[json["contagio"]],
        contactoFocal:
            json["contacto_focal"] == null ? null : json["contacto_focal"],
        centroAislamiento: json["centro_aislamiento"] == null
            ? null
            : json["centro_aislamiento"],
        centroDiagnostico:
            centroDiagnosticoValues.map[json["centro_diagnostico"]],
        posibleProcedenciaContagio: List<String>.from(
            json["posible_procedencia_contagio"].map((x) => x)),
        sujetosRiesgo:
            json["sujetos_riesgo"] == null ? null : json["sujetos_riesgo"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "pais": pais,
        "edad": edad == null ? null : edad,
        "sexo": sexoValues.reverse[sexo],
        "arribo_a_cuba_foco": arriboACubaFoco == null ? null : arriboACubaFoco,
        "consulta_medico": consultaMedico == null ? null : consultaMedico,
        "municipio_detección":
            municipioDeteccin == null ? null : municipioDeteccin,
        "provincia_detección":
            provinciaDeteccin == null ? null : provinciaDeteccin,
        "dpacode_municipio_deteccion": dpacodeMunicipioDeteccion,
        "dpacode_provincia_deteccion": dpacodeProvinciaDeteccion,
        "provincias_visitadas":
            List<dynamic>.from(provinciasVisitadas.map((x) => x)),
        "dpacode_provincias_visitadas":
            List<dynamic>.from(dpacodeProvinciasVisitadas.map((x) => x)),
        "contagio": contagioValues.reverse[contagio],
        "contacto_focal": contactoFocal == null ? null : contactoFocal,
        "centro_aislamiento":
            centroAislamiento == null ? null : centroAislamiento,
        "centro_diagnostico":
            centroDiagnosticoValues.reverse[centroDiagnostico],
        "posible_procedencia_contagio":
            List<dynamic>.from(posibleProcedenciaContagio.map((x) => x)),
        "sujetos_riesgo": sujetosRiesgo == null ? null : sujetosRiesgo,
      };
}

enum CentroDiagnostico { IPK, LSC, LVC }

final centroDiagnosticoValues = EnumValues({
  "ipk": CentroDiagnostico.IPK,
  "lsc": CentroDiagnostico.LSC,
  "lvc": CentroDiagnostico.LVC
});

enum Contagio { IMPORTADO, INTRODUCIDO, AUTOCTONO, DESCONOCIDO }

final contagioValues = EnumValues({
  "importado": Contagio.IMPORTADO,
  "introducido": Contagio.INTRODUCIDO,
  "autoctono": Contagio.AUTOCTONO,
  "desconocido": Contagio.DESCONOCIDO
});

enum Sexo { HOMBRE, MUJER }

final sexoValues = EnumValues({"hombre": Sexo.HOMBRE, "mujer": Sexo.MUJER});

class Centros {
  String id;
  String nombre;
  String provincia;
  String dpacodeProvincia;

  Centros({
    this.id,
    this.nombre,
    this.provincia,
    this.dpacodeProvincia,
  });

  factory Centros.fromJson(Map<String, dynamic> json) => Centros(
        id: json["id"],
        nombre: json["nombre"],
        provincia: json["provincia"],
        dpacodeProvincia: json["dpacode_provincia"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "provincia": provincia,
        "dpacode_provincia": dpacodeProvincia,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
