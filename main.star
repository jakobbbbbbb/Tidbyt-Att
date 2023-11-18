load("cache.star", "cache")
load("encoding/json.star", "json")
load("http.star", "http")
load("humanize.star", "humanize")
load("render.star", "render")
load("time.star", "time")
load("encoding/base64.star", "base64")

#Bus stop ID is found from: https://stoppested.entur.org/?stopPlaceId=NSR:StopPlace:42029

stopURL = "https://mpolden.no/atb/v2/departures/42029?direction=outbound"

def main():
    response_data_cache = cache.get("response_data")
    if response_data_cache != None:
        # print("Hit! Displaying cached data.")
         response_data = json.decode(response_data_cache)
    else:
        # print("Miss! Calling MBTA API.")
        rep = http.get(stopURL)
        if rep.status_code != 200:
            fail("MBTA API request failed with status %d", rep.status_code)
        response_data = rep.json()
        cache.set("response_data", json.encode(response_data), ttl_seconds = 10)

    depTimes = []
    busNO = []
    busINFO = response_data["departures"]
    counter = 0
    counterLIM = 2
    for deps in busINFO:
        departure = deps["scheduledDepartureTime"]
        busnumber = deps["line"]
        if counter < counterLIM and busnumber == "3":
            depTimes.append(departure)
            busNO.append(busnumber)
            counter += 1

    return render.Root(
            child = render.Column(
                main_align = "space_evenly",
                children = [
                    render.Text("Linje: " + busNO[0], color = "#FCF7F8"),
                    render.Text("Avgang: " + depTimes[0][11:16], color = "#07BEB8"),
                    #render.Text("Linje: " + busNO[1], color = "#FCF7F8"),
                    render.Text("           " + depTimes[1][11:16], color = "#07BEB8")
                ]
            )
        )