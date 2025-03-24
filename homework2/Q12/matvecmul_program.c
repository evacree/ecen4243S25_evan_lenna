#include <stdio.h>

void matvecmul(int A[], int x[], int y[], int m, int n) {
    int i, j, sum;
    for (i = 0; i < m; i++) {
        sum = 0;  // Reset sum at the start of each row
        for (j = 0; j < n; j++) {
            sum += A[i * n + j] * x[j];  // Matrix-vector multiplication
        }
        y[i] = sum;  // Store the result in the y vector
    }
}

void main(void) {
    int A[6] = {1, 2, 3, 4, 5, 6};  // Example 2x3 matrix (flattened 1D array)
    int x[3] = {7, 8, 9};            // Example 3x1 vector
    int y[2];                        // Resulting vector (2x1)
    
    // Perform matrix-vector multiplication: y = A * x
    matvecmul(A, x, y, 2, 3);

    // Print the resulting vector y
    printf("Resulting vector y:\n");
    for (int i = 0; i < 2; i++) {
        printf("y[%d] = %d\n", i, y[i]);
    }
}
