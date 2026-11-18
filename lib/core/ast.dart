import 'rational.dart';

abstract class Node {
  const Node();
}

class NumberNode extends Node {
  final double value;

  /// Exact value of the literal as written, when it is a plain decimal.
  final Rational? exact;

  const NumberNode(this.value, [this.exact]);
}

class VariableNode extends Node {
  final String name;
  const VariableNode(this.name);
}

class UnaryNode extends Node {
  final String op;
  final Node child;
  const UnaryNode(this.op, this.child);
}

class BinaryNode extends Node {
  final String op;
  final Node left;
  final Node right;
  const BinaryNode(this.op, this.left, this.right);
}

class PostfixNode extends Node {
  final String op;
  final Node child;
  const PostfixNode(this.op, this.child);
}

class CallNode extends Node {
  final String name;
  final List<Node> args;
  const CallNode(this.name, this.args);
}
