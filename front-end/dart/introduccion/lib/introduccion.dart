// Comentario de una sola linea
/*
  Es un comentario
  de varias 
  lineas
*/
/// comentario de documentación


int suma(int numero1, int numero2) {
  return numero1+numero2;
}


void indicaciones() {
  print("Bienvenidos a Flutter");
  print("Iniciando con Dart");
}

class Animal {
   final String nombre;
   final String color;

   //const Animal({required this.nombre, required this.color});
   const Animal({required this.nombre, this.color = "negro"});
}

void main() {
    var nombre      = "Jorge";
    String apellido = "Hernandez";
    double salario  = 4599.89;
    bool soltero    = false;

    final puesto    = "Profesor"; // se asigna 1 vez en tiempo de ejecucion
    const pi        = 3.1416;  //se asigna en tipo de compilacion 

    print(nombre);
    print(apellido);
    print(salario);
    print(soltero);
    print(puesto);
    print(pi);

    dynamic cambia = 5;
    print(cambia);
    cambia = "Otro dato";
    print(cambia);

    // manipulacion de null satefy
    String? materia = null;
    print(materia ?? "Materia no asignada");
    print(materia?.length ?? 0);

    late String jwt;
    print("Hola mundo");
    jwt = "mi token secreto";
    print(jwt);

    // condicionales
    int edad        = 19;
    if (edad > 18) {
      if (edad < 40) {
        print("Adulto joven");
      } else {
        print("Adulto mayor");
      }
    } else {
      print("Menor de edad");
    }

    // ciclos iterativos
    for (int i=1; i <= 5; i++) {
       print(i);
    }

    edad = 0;
    while (edad < 18) {
      print("Vivo con mis papas");
      edad = edad + 1; //edad +=1 ;
    }
    print("Vivo solo");

    var comidas = ['pizza','hamburguesa','tacos','tortas'];
    for (final comida in comidas) {
      print(comida);
    }

    // Colecciones
   List<String> alumnos = ["Carlos","Sofia","Luis","Pedro"];
   alumnos.add("Maria");
   print(alumnos[2]);

   Map<String, double> calificaciones = {
      "Carlos": 89,
      "Sofia": 98.3,
      "Pedro": 88
   };
   
   calificaciones['Pedro'] = 100;
   print(calificaciones);

   indicaciones();
   print(suma(4, 5));

   int resta(int numero1, int numero2) => numero1 - numero2;

   print(resta(4,5));

   final perro  = Animal(nombre: "duque", color: "miel");
   print(perro.nombre);
   print(perro.color);

   final gato = Animal(nombre: "tom");
   print(gato.nombre);
   print(gato.color);

}

