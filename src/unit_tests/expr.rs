use super::*;
use crate::types::ProblemSize;
use std::collections::{HashMap, HashSet};

#[test]
fn test_expr_const_eval() {
    let e = Expr::Const(42.0);
    let size = ProblemSize::new(vec![]);
    assert_eq!(e.eval(&size), 42.0);
}

#[test]
fn test_expr_var_eval() {
    let e = Expr::Var("n");
    let size = ProblemSize::new(vec![("n", 10)]);
    assert_eq!(e.eval(&size), 10.0);
}

#[test]
fn test_expr_add_eval() {
    // n + 3
    let e = Expr::add(Expr::Var("n"), Expr::Const(3.0));
    let size = ProblemSize::new(vec![("n", 7)]);
    assert_eq!(e.eval(&size), 10.0);
}

#[test]
fn test_expr_mul_eval() {
    // 3 * n
    let e = Expr::mul(Expr::Const(3.0), Expr::Var("n"));
    let size = ProblemSize::new(vec![("n", 5)]);
    assert_eq!(e.eval(&size), 15.0);
}

#[test]
fn test_expr_pow_eval() {
    // n^2
    let e = Expr::pow(Expr::Var("n"), Expr::Const(2.0));
    let size = ProblemSize::new(vec![("n", 4)]);
    assert_eq!(e.eval(&size), 16.0);
}

#[test]
fn test_expr_exp_eval() {
    let e = Expr::Exp(Box::new(Expr::Const(1.0)));
    let size = ProblemSize::new(vec![]);
    assert!((e.eval(&size) - std::f64::consts::E).abs() < 1e-10);
}

#[test]
fn test_expr_log_eval() {
    let e = Expr::Log(Box::new(Expr::Const(std::f64::consts::E)));
    let size = ProblemSize::new(vec![]);
    assert!((e.eval(&size) - 1.0).abs() < 1e-10);
}

#[test]
fn test_expr_sqrt_eval() {
    let e = Expr::Sqrt(Box::new(Expr::Const(9.0)));
    let size = ProblemSize::new(vec![]);
    assert_eq!(e.eval(&size), 3.0);
}

#[test]
fn test_expr_complex() {
    // n^2 + 3*m
    let e = Expr::add(
        Expr::pow(Expr::Var("n"), Expr::Const(2.0)),
        Expr::mul(Expr::Const(3.0), Expr::Var("m")),
    );
    let size = ProblemSize::new(vec![("n", 4), ("m", 2)]);
    assert_eq!(e.eval(&size), 22.0); // 16 + 6
}

#[test]
fn test_expr_variables() {
    let e = Expr::add(
        Expr::pow(Expr::Var("n"), Expr::Const(2.0)),
        Expr::mul(Expr::Const(3.0), Expr::Var("m")),
    );
    let vars = e.variables();
    assert_eq!(vars, HashSet::from(["n", "m"]));
}

#[test]
fn test_expr_substitute() {
    // n^2, substitute n → (a + b)
    let e = Expr::pow(Expr::Var("n"), Expr::Const(2.0));
    let replacement = Expr::add(Expr::Var("a"), Expr::Var("b"));
    let mut mapping = HashMap::new();
    mapping.insert("n", &replacement);
    let result = e.substitute(&mapping);
    // Should be (a + b)^2
    let size = ProblemSize::new(vec![("a", 3), ("b", 2)]);
    assert_eq!(result.eval(&size), 25.0); // (3+2)^2
}

#[test]
fn test_expr_display_simple() {
    assert_eq!(format!("{}", Expr::Const(5.0)), "5");
    assert_eq!(format!("{}", Expr::Var("n")), "n");
}

#[test]
fn test_expr_display_add() {
    let e = Expr::add(Expr::Var("n"), Expr::Const(3.0));
    assert_eq!(format!("{e}"), "n + 3");
}

#[test]
fn test_expr_display_mul() {
    let e = Expr::mul(Expr::Const(3.0), Expr::Var("n"));
    assert_eq!(format!("{e}"), "3 * n");
}

#[test]
fn test_expr_display_pow() {
    let e = Expr::pow(Expr::Var("n"), Expr::Const(2.0));
    assert_eq!(format!("{e}"), "n^2");
}

#[test]
fn test_expr_display_exp() {
    let e = Expr::Exp(Box::new(Expr::Var("n")));
    assert_eq!(format!("{e}"), "exp(n)");
}

#[test]
fn test_expr_display_nested() {
    // n^2 + 3 * m
    let e = Expr::add(
        Expr::pow(Expr::Var("n"), Expr::Const(2.0)),
        Expr::mul(Expr::Const(3.0), Expr::Var("m")),
    );
    assert_eq!(format!("{e}"), "n^2 + 3 * m");
}

#[test]
fn test_expr_is_polynomial() {
    assert!(Expr::Var("n").is_polynomial());
    assert!(Expr::pow(Expr::Var("n"), Expr::Const(2.0)).is_polynomial());
    assert!(!Expr::Exp(Box::new(Expr::Var("n"))).is_polynomial());
    assert!(!Expr::Log(Box::new(Expr::Var("n"))).is_polynomial());
}
