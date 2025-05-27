const apiKey = process.env.MY_MC_API_KEY;

const result = fetch('https://api.my-mc.link/my-hash',{
    method: "GET",
    headers: {
        'Accept': 'application/json', 'Content-Type': 'application/json', 'x-my-mc-auth': apiKey}
    })
        .then(async response => {
            const r = await response.json();
            if (r.success == true) {
                console.log(r.message);
            }      
        })
