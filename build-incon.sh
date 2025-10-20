cd /home/nitai/projects/work/incon24/
git reset --hard
cp app.json.nbarran app.json
npx expo prebuild --clean
eas build --platform android --profile preview --local
cp app.json.kbelgrove app.json
nautilus .
