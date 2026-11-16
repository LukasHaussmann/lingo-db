// RUN: env LINGODB_EXECUTION_MODE=DEFAULT run-mlir %s | FileCheck %s
// RUN: env LINGODB_EXECUTION_MODE=C run-mlir %s | FileCheck %s
// RUN: %if baseline-backend %{LINGODB_EXECUTION_MODE=BASELINE run-mlir %s | FileCheck %s %}

// Hashing a string longer than 12 bytes calls into the runtime (hashVarLenData). The C backend compiles the query into a
// shared library that must reach this function without the host binary exporting it.
module {
    func.func @main () {
         %str1 = db.constant ( "a string too long to be stored inline" ) :!db.string
         %str2 = db.constant ( "a string too long to be stored inline" ) :!db.string
         %hash1 = db.hash %str1 : !db.string
         %hash2 = db.hash %str2 : !db.string
//CHECK: index([[HASH:[0-9]+]])
//CHECK-NEXT: index([[HASH]])
         db.runtime_call "DumpValue" (%hash1) : (index) -> ()
         db.runtime_call "DumpValue" (%hash2) : (index) -> ()
         return
    }
}
