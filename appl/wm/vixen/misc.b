dropindent(c: ref Cmd)
{
	for(i := 8; i > 0; i--)
		case c.get() {
		' ' =>	;
		'\t' =>	return;
		* =>	c.unget(); return;
		}
}

# (un)indent text
indent(cs, ce: ref Cursor, rev: int)
{
	s := text.get(cs, ce);
	r: string;
	if(rev) {
		c := Cmd.mk(s);
		while(c.more()) {
			dropindent(c);
			while((x := c.get()) >= 0) {
				r[len r] = x;
				if(x == '\n')
					break;
			}
		}
	} else {
		if(len s > 0 && s[0] != '\n')
			r[len r] = '\t';
		for(i := 0; i < len s; i++) {
			r[len r] = s[i];
			if(s[i] == '\n' && i+1 < len s && s[i+1] != '\n')
				r[len r] = '\t';
		}
	}
	
	textdel(Cchange|Csetcursorlo, cs, ce);
	textins(Cchange, nil, r);
	cursorset(cursor.mvfirst());
}

# could try harder with more broader unicode support
swapcasex(c: int): int
{
	case c {
	'a' to 'z' =>	return c-'a'+'A';
	'A' to 'Z' =>	return c-'A'+'a';
	* =>		return c;
	}
}

swapcase(s: string): string
{
	r: string;
	for(i := 0; i < len s; i++)
		r[len r] = swapcasex(s[i]);
	return r;
}

# remove empty lines, replace newline by a space
join(cs, ce: ref Cursor, space: int)
{
	s := text.get(cs, ce);

	r := "";
	n := len s;
	if(n >= 0 && s[n-1] == '\n')
		--n;
	for(i := 0; i < n; i++)
		case s[i] {
		'\n' =>
			if(space)
				r[len r] = ' ';
			while(i+1 < len s && s[i+1] == '\n')
				++i;
		* =>
			r[len r] = s[i];
		}
	if(n == len s-1)
		r[len r] = '\n';

	textdel(Cchange|Csetcursorlo, cs, ce);
	textins(Cchange, nil, r);
}

hasnewline(s: string): int
{
	for(i := 0; i < len s; i++)
		if(s[i] == '\n')
			return 1;
	return 0;
}
