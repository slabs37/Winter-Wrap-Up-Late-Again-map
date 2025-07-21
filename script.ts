import * as rm from "https://deno.land/x/remapper@4.1.0/src/mod.ts"
import * as bundleInfo from './bundleinfo.json' with { type: 'json' }

const pipeline = await rm.createPipeline({ bundleInfo })

const bundle = rm.loadBundle(bundleInfo)
const materials = bundle.materials
const prefabs = bundle.prefabs

// ----------- { SCRIPT } -----------

async function doMap(file: rm.DIFFICULTY_NAME) {
    const map = await rm.readDifficultyV3(pipeline, file)

    // remove all environment
    rm.environmentRemoval(map, ['Environment', 'GameCore'])

    // Level info stuff
    map.difficultyInfo.requirements = [
        'Chroma',
        'Noodle Extensions',
        'Vivify',
    ]

    map.difficultyInfo.settingsSetter = {
        graphics: {
            screenDisplacementEffectsEnabled: true,
        },
        chroma: {
            disableEnvironmentEnhancements: false,
        },
        playerOptions: {
            leftHanded: rm.BOOLEAN.False,
            noteJumpDurationTypeSettings: 'Dynamic',
        },
        colors: {},
        environments: {},
    }

    rm.setRenderingSettings(map, {
        qualitySettings: {
            realtimeReflectionProbes: rm.BOOLEAN.True,
            shadows: rm.SHADOWS.HardOnly,
            shadowDistance: 64,
            shadowResolution: rm.SHADOW_RESOLUTION.VeryHigh,
            
        },
        renderSettings: {
            fog: rm.BOOLEAN.True,
            fogEndDistance: 64,
        },
    })

    // load prefabs

    const balloon = prefabs.balloon.instantiate(map, 0)
    const Scene1 = prefabs.scene.instantiate(map, 0)
    const Scene2 = prefabs.scene2.instantiate(map, 0)
    const birds = prefabs.birds.instantiate(map, 0)

    // material assign stuff
    
    materials.doorrot.set(map, {
            _Rotation: ["baseEnergy.s5"],
        }, 0, 7000)

    // note path and assignment

    rm.assignObjectPrefab(map, {
        colorNotes: {
            track: 'mainNotes',
            asset: prefabs.customnote.path,
            debrisAsset: prefabs.customnotedebris.path,
        },
    })

    map.allNotes.forEach(note => {
            note.track.add('mainNotes')
        }
    )

    rm.assignPathAnimation(map, {
        track: 'sc1Note',
        animation: {
            offsetPosition: [
                [0, -100, 0, 0],
                [0, -5, 0, 0.2],
                [0, -0.25, 0, 0.35, "easeOutSine"],
            ]
        },
    })

    rm.assignPathAnimation(map, {
        track: 'sc2RNote',
        animation: {
            offsetPosition: [
                [10,-3,-50,0],
                [0,-0.1,0,0.35,"easeInOutQuad"],
                [0,0,0, 0.45]
            ],
            dissolve: [
                [0, 0],
                [0, 0.09],
                [1.0, 0.1]
            ]
        },
    })

    rm.assignPathAnimation(map, {
        track: 'sc2LNote',
        animation: {
            offsetPosition: [
                [-10,-3,-50,0],
                [0,-0.1,0,0.35,"easeInOutQuad"],
                [0,0,0, 0.45]
            ],
            dissolve: [
                [0, 0],
                [0, 0.09],
                [1.0, 0.1]
            ]
        },
    })

    map.colorNotes.forEach(note => {
        //Scene 1
        if (note.beat >= 0 && note.beat <= 212) {
            note.unsafeCustomData._disableSpawnEffect = rm.BOOLEAN.True
            note.noteJumpStartBeatOffset = 1
            note.noteJumpMovementSpeed = 10
            note.track.add('sc1Note')
        }
        if (note.beat >= 213 && note.beat <= 289) {
            note.unsafeCustomData._disableSpawnEffect = rm.BOOLEAN.True
            note.noteJumpStartBeatOffset = 1
            note.noteJumpMovementSpeed = 10
            //note.color 1 is right hand, 0 is left hand
            if (note.color) {
                note.track.add('sc2RNote')
            } else {
                note.track.add('sc2LNote')
            }
        }
    })

}

await Promise.all([
    doMap('ExpertPlusStandard')
])

// ----------- { OUTPUT } -----------

pipeline.export({
    outputDirectory: '../Winter Wrap Up'
})
