REM SETUP RUBY
REM set ?? path\PracaInz-Program\bin\Ruby193\lib\ruby\gems   


REM SETUP MONGO

echo logpath = %CD%\PracaInz-Program\log > %CD%\PracaInz-Program\bin\mongodb\mongod.cfg

start %CD%\PracaInz-Program\bin\mongodb\bin\mongod.exe --config %CD%\PracaInz-Program\bin\mongodb\mongod.cfg --install

net start MongoDB

start %CD%\PracaInz-Program\bin\mongodb\bin\mongod.exe --dbpath %CD%\PracaInz-Program\db