from setuptools import setup

setup(
    name='dummy_package',
    version='0.0.0',
    install_requires=['Jinja2==2.9.5', 'docopt'],
    packages=['hooks'],
    entry_points={
        'console_scripts':
        ["convert-jinja2-into-html=hooks.convert_jinja2_into_html:main"]
    })