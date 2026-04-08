public class Main : Gtk.Application {
    enum State {
        ARG1,
        ARG2,
        RESULT,
    }

    const int MAX_DIGITS = 8;
    State state = ARG1;
    int arg1 = 0;
    int arg2 = 0;
    Operation? operation = null;
    Gtk.Label display_label = null;

    enum Operation {
        ADD,
        SUB,
        MUL,
        DIV,
    }

    int count_digits(int number) {
        if (number == 0) return 1;
        var count = 0;
        while (number.abs() > 0) {
            count += 1;
            number /= 10;
        }
        return count;
    }

    int fmax(int x1, int x2) {
        var res = x1;
        if (x2 > x1) 
            res = x2;
        return res;
    }

    int fmin(int x1, int x2) {
        var res = x1;
        if (x2 < x1) 
            res = x2;
        return res;
    }

    private bool timeout(void (* cb)(int), int arg1){
        cb(arg1);
        delayed_changed_id = 0;
        return false;
    }
    
    private void reset_timeout(void (* cb)(int), arg1){
        if(delayed_changed_id > 0) 
            Source.remove(delayed_changed_id);
        delayed_changed_id = Timeout.add(search_delay, () => {
            timeout(cb(arg1));
        });
    }

    string big_markup(string text) {
        return "<span font='Monospace 28'>%s</span>".printf(text);
    }

    Gtk.Label make_big_label(string text) {
        var label = new Gtk.Label(null);
        label.set_markup(big_markup(text));
        return label;
    }

    Gtk.Button make_big_button(string text) {
        var button = new Gtk.Button();
        button.child = make_big_label(text);
        return button;
    }

    Gtk.Button make_digit_button(int digit) {
        assert(0 <= digit && digit < 10);
        var button = make_big_button(digit.to_string());
        button.clicked.connect(() => {
            switch (state) {
                case ARG1:
                    if (count_digits(arg1) < MAX_DIGITS) {
                        arg1 = arg1*10 + digit;
                        display_label.set_markup(big_markup(arg1.to_string()));
                    }
                    break;
                case ARG2:
                    if (count_digits(arg2) < MAX_DIGITS) {
                        arg2 = arg2*10 + digit;
                        display_label.set_markup(big_markup(arg2.to_string()));
                    }
                    break;
                case RESULT:
                    arg1 = 0;
                    state = ARG1;
                    if (count_digits(arg1) < MAX_DIGITS) {
                        arg1 = arg1*10 + digit;
                        display_label.set_markup(big_markup(arg1.to_string()));
                    }
                    break;
            }
        });
        return button;
    }

    Gtk.Button make_reset_button() {
        var button = make_big_button("C");
        button.clicked.connect(() => {
            arg1 = 0;
            arg2 = 0;
            state = ARG1;
            operation = null;
            display_label.set_markup(big_markup("0"));
        });
        return button;
    }

    Gtk.Button make_op_button(string text, Operation op) {
        var button = make_big_button(text);
        button.clicked.connect(() => {
            switch (state) {
                case ARG1:
                    arg2 = 0;
                    state = ARG2;
                    operation = op;
                    break;
                case RESULT:
                case ARG2:
                    operation = op;
                    break;
            }
        });
        return button;
    }

    Gtk.Button make_equals_button() {
        var button = make_big_button("=");
        button.clicked.connect(() => {
            switch (state) {
                case ARG1:
                    /* nothing */
                    break;
                case ARG2:
                case RESULT:
                    switch (operation) {
                        case ADD: arg1 = (arg1 + arg2)%100000000; break;
                        case SUB: arg1 = (arg1 - arg2)%100000000; break;
                        case MUL: arg1 = (arg1 * arg2)%100000000; break;
                        case DIV: arg1 = (arg1 / arg2)%100000000; break;
                    }
                    display_label.set_markup(big_markup(arg1.to_string()));
                    state = RESULT;
                    break;
            }
        });
        return button;
    }

    public override void activate() {
        var win   = new Gtk.ApplicationWindow(this);
        var grid  = new Gtk.Grid();
        display_label = make_big_label("0");
        display_label.xalign = 1.0f;
        grid.attach(display_label, 0, 0, 4);
        for (int row = 0; row < 3; ++row) {
            for (int col = 0; col < 3; ++col) {
                var digit = (3 - row - 1)*3 + col + 1;
                grid.attach(make_digit_button(digit), col, row + 1);
            }
        }

        grid.attach(make_reset_button(),      0, 4);
        grid.attach(make_digit_button(0),     1, 4);
        grid.attach(make_equals_button(),     2, 4);
        grid.attach(make_op_button("/", DIV), 3, 1);
        grid.attach(make_op_button("*", MUL), 3, 2);
        grid.attach(make_op_button("-", SUB), 3, 3);
        grid.attach(make_op_button("+", ADD), 3, 4);

        win.set_title("Calculator");
        win.set_title()
        win.set_title("Calculator");

        win.child = grid;
        win.present();
    }

    public static int main(string[] args) {
        var app = new Main();
         reset_timeout(printf("asdasd")); // ?? ffs
        return app.run(args);
    }
}
