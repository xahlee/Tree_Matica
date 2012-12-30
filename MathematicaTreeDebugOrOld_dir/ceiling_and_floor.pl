#_____ Ceiling _____ _____

=pod

B<Ceiling>

Ceiling($real) returns the larger of the two neighboring integers of $real.

Example:

 Ceiling(3.7); # returns 4

 Ceiling(-3.7); # returns -3

=cut

# implementation note:
# Dependent functions: (none).

push (@EXPORT, q(Ceiling));
push (@EXPORT_OK, q(Ceiling));

sub Ceiling ($) {if ($_[0] > 0 and $_[0] != int($_[0])) {return (int $_[0] +1);} else {return (int $_[0]);};};

#_____ Floor _____ _____

=pod

B<Floor>

Floor($real) returns the smaller of the two neighboring integers of $real.

Example:

 Floor(3.7); # returns 3

 Floor(-3.7); # returns -4

=cut

# implementation note:
# Dependent functions: (none).

push (@EXPORT, q(Floor));
push (@EXPORT_OK, q(Floor));

sub Floor ($) {if ($_[0] < 0 and $_[0] != int($_[0])) {return (int $_[0] -1);} else {return (int $_[0]);} ;};

