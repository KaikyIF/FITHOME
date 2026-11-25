import 'package:flutter/material.dart';

enum CategoriaExercicio {
  todos('Todos', Icons.fitness_center),
  cardio('Cardio', Icons.local_fire_department_outlined),
  forca('Força', Icons.fitness_center),
  flexibilidade('Flexibilidade', Icons.favorite_border),
  hiit('HIIT', Icons.bolt_outlined);

  const CategoriaExercicio(this.rotulo, this.icone);

  final String rotulo;
  final IconData icone;
}

typedef FichaExercicio = ({
  Set<CategoriaExercicio> categorias,
  String descricao,
  String nivel,
  String musculos,
  int segundos,
  List<String> instrucoes,
});

const fichasExercicios = <String, FichaExercicio>{
  'Flexão de Braço': (
    categorias: {CategoriaExercicio.forca},
    descricao: 'Exercício fundamental para força da parte superior do corpo.',
    nivel: 'Intermediário',
    musculos: 'Peito, tríceps e ombros',
    segundos: 35,
    instrucoes: [
      'Apoie as mãos no chão, um pouco além da largura dos ombros.',
      'Mantenha o tronco alinhado e flexione os cotovelos para baixar o peito.',
      'Empurre o chão para voltar. Apoie os joelhos se precisar reduzir a dificuldade.',
    ],
  ),
  'Agachamento': (
    categorias: {CategoriaExercicio.forca},
    descricao: 'Exercício para fortalecer os membros inferiores.',
    nivel: 'Iniciante',
    musculos: 'Pernas e glúteos',
    segundos: 35,
    instrucoes: [
      'Posicione os pés na largura dos ombros.',
      'Leve o quadril para trás e flexione os joelhos, mantendo-os alinhados com os pés.',
      'Pressione os pés contra o chão para se levantar.',
    ],
  ),
  'Burpee': (
    categorias: {CategoriaExercicio.cardio, CategoriaExercicio.hiit},
    descricao: 'Movimento de corpo inteiro para trabalhar o condicionamento.',
    nivel: 'Avançado',
    musculos: 'Corpo todo',
    segundos: 25,
    instrucoes: [
      'Agache e apoie as mãos no chão.',
      'Leve os pés para trás até a posição de prancha.',
      'Traga os pés de volta e levante-se. Dê passos no lugar dos saltos para reduzir o impacto.',
    ],
  ),
  'Prancha': (
    categorias: {CategoriaExercicio.forca},
    descricao:
        'Exercício isométrico para fortalecer a região central do corpo.',
    nivel: 'Intermediário',
    musculos: 'Abdômen e ombros',
    segundos: 25,
    instrucoes: [
      'Apoie os antebraços com os cotovelos sob os ombros.',
      'Estenda as pernas e alinhe cabeça, tronco e quadril.',
      'Mantenha a posição e respire normalmente.',
    ],
  ),
  'Abdominal': (
    categorias: {CategoriaExercicio.forca},
    descricao: 'Movimento controlado para fortalecer o abdômen.',
    nivel: 'Iniciante',
    musculos: 'Abdômen',
    segundos: 30,
    instrucoes: [
      'Deite de costas com joelhos dobrados e pés no chão.',
      'Eleve os ombros contraindo o abdômen, sem puxar o pescoço.',
      'Volte devagar até os ombros tocarem o chão.',
    ],
  ),
  'Polichinelo': (
    categorias: {CategoriaExercicio.cardio, CategoriaExercicio.hiit},
    descricao: 'Movimento aeróbico que combina saltos com elevação dos braços.',
    nivel: 'Iniciante',
    musculos: 'Pernas e ombros',
    segundos: 30,
    instrucoes: [
      'Comece em pé, com pés juntos e braços ao lado do corpo.',
      'Abra os pés e eleve os braços ao mesmo tempo.',
      'Retorne à posição inicial e repita em ritmo controlado.',
    ],
  ),
  'Alongamento Posterior da Coxa': (
    categorias: {CategoriaExercicio.flexibilidade},
    descricao:
        'Alongamento para trabalhar a mobilidade da parte de trás da coxa.',
    nivel: 'Iniciante',
    musculos: 'Posteriores da coxa',
    segundos: 40,
    instrucoes: [
      'Sente-se e estenda uma perna, deixando a outra dobrada.',
      'Incline o tronco pela articulação do quadril até sentir tensão leve atrás da coxa.',
      'Sustente sem balanços e troque de lado na metade do tempo.',
    ],
  ),
};
