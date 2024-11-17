#include <mruby.h>
#include <mruby/irep.h>
#include <mruby/compile.h>
#include <mruby/string.h> // Include for string functions
#include "agogo.c"

int main()
{
    mrb_state* mrb = mrb_open();
    if(!mrb)
    {
        return -1;
    }
    // Create a parser state for potential error reporting
    mrbc_context* context = mrbc_context_new(mrb);
    // Load and parse the bytecode
    mrb_value result = mrb_load_irep_cxt(mrb, app, context);
    // Check for errors
    if(mrb_exception_p(result))
    {
        // An error occurred during loading or execution
        mrb_value exception = mrb_obj_value(mrb->exc);
        // Print the error message (assuming it's a String)
        if(mrb_string_p(exception))
        {
            const char* error_message = mrb_string_value_cstr(mrb, &exception);
            fprintf(stderr, "mruby error: %s\n", error_message);
        }
        else
        {
            fprintf(stderr, "An unknown mruby error occurred.\n");
        }
        // Optionally, inspect the backtrace for more details
        // mrb_print_backtrace(mrb);
        mrbc_context_free(mrb, context);
        mrb_close(mrb);
        return -1;
    }
    // Bytecode loaded and executed successfully
    mrbc_context_free(mrb, context);
    mrb_close(mrb);
    return 0;
}
