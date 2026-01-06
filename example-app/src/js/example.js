import { Example } from 'capacitor-linkrunner';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    Example.echo({ value: inputValue })
}
