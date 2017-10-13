# *-* coding=utf-8 *-*
"""
Convert Jinja2 Template into html.

Usage:
    ./convert_jinja2_into_html.py [<filename>...] [--filename_pattern=<p>] [--filename_repl=<r>]
    ./convert_jinja2_into_html.py (-h | --help)

Options:
    -h --help                   Show this screen.
    --filename_pattern=<p>      The filename replace pattern [default: \.html\.tmpl].
    --filename_repl=<r>         The filename replace result  [default: .html]
"""
import jinja2
import json
import docopt
import re


def main_impl(filenames, pattern, repl):
    for filename in filenames:
        if filename.endswith(".json"):
            filename = filename[:-len(".json")] + ".tmpl"
        tmpl = jinja2.Template(open(filename).read().decode('utf-8'))
        with open(filename[:-len(".tmpl")] + ".json") as f:
            data = json.load(f)
        buf = tmpl.render(data).encode('utf-8')
        new_filename = re.sub(pattern=pattern, repl=repl, string=filename)
        with open(new_filename, 'w') as f:
            f.write(buf)


def main():
    args = docopt.docopt(__doc__)
    main_impl(args['<filename>'], args['--filename_pattern'],
              args['--filename_repl'])


if __name__ == '__main__':
    main()
