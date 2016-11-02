context("char.diff")


cor.spearman <- function(X,Y) {
    return(abs(cor(X,Y, method = "spearman")))
}

test_that("char.diff works for binary characters", {
    A <- c(1,0,0,0,0)
    B <- c(0,1,1,1,1)

    #Correlation is 1
    expect_equal(abs(cor(A,B)), 1)
    #Correlation is triangular
    expect_equal(abs(cor(A,B)), abs(cor(B,A)))
    #Difference is 0
    expect_equal(char.diff(A,B), 0)
    #Difference is triangular
    expect_equal(char.diff(A,B), char.diff(B,A))

    C <- c(1,1,0,0,0)

    #Correlation is 0.6
    expect_equal(round(abs(cor(A,C)), digit = 5), 0.61237)
    #Correlation is triangular
    expect_equal(abs(cor(A,C)), abs(cor(C,A)))
    #Difference is 0.4
    expect_equal(char.diff(A,C), 0.4)
    #Difference is triangular
    expect_equal(char.diff(A,C), char.diff(C,A))

    D <- c(0,1,1,0,0)

    #Correlation is 0.6
    expect_equal(round(abs(cor(A,D)), digit = 5), 0.40825)
    #Correlation is triangular
    expect_equal(abs(cor(A,D)), abs(cor(D,A)))
    #Difference is 0.4
    expect_equal(char.diff(A,D), 0.8)
    #Difference is triangular
    expect_equal(char.diff(A,D), char.diff(D,A))

    E <- c(1,0,0,1,1)

    #Correlation is equal to D
    expect_equal(abs(cor(D,E)), 1)
    #Correlation is triangular (with D)
    expect_equal(abs(cor(A,E)), abs(cor(A,D)))
    #Difference is equal to D
    expect_equal(char.diff(D,E), 0)
    #Difference is triangular (with D)
    expect_equal(char.diff(A,E), char.diff(A,D))
}