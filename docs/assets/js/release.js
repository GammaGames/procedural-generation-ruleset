let username = "gammagames";
let repo = "procedural-generation-ruleset";

window.onload = () => {
    fetch(`https://api.github.com/repos/${username}/${repo}/releases/latest`).then(response => {
        response.json().then(json => {
            let release_el = document.getElementById("latest_tag");
            release_el.textContent = `release ${json.tag_name}`;
            release_el.href = json.html_url;
            json.assets.forEach(file => {
                let name = file.name.split(".")[0];
                let asset_el = document.getElementById(`${name}_link`);
                if(asset_el) {
                    asset_el.href = file.browser_download_url;
                }
            });
        });
    });
}
